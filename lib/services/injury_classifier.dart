// lib/services/injury_classifier.dart
//
// KEY FIX: Every public method now calls _runInference() exactly ONCE
// and derives everything (label, confidence, top-2, all scores) from
// that single result.  No more double/triple inference runs.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/labels.dart';
import 'tokenizer.dart';

// ── Result object returned by classifyFull() ──────────────────────────────

class ClassificationResult {
  /// All 12 classes sorted by probability descending.
  /// Each entry: { "label": String, "index": int, "confidence": double }
  final List<Map<String, dynamic>> allScores;

  ClassificationResult(this.allScores);

  // Convenience getters derived from allScores — no extra inference needed.

  String get top1Label       => allScores[0]["label"] as String;
  double get top1Confidence  => allScores[0]["confidence"] as double;

  String get top2Label       => allScores.length > 1
      ? allScores[1]["label"] as String
      : top1Label;
  double get top2Confidence  => allScores.length > 1
      ? allScores[1]["confidence"] as double
      : 0.0;

  double get gap => top1Confidence - top2Confidence;

  /// Find the confidence of any specific label, regardless of rank.
  double confidenceOf(String label) {
    for (final s in allScores) {
      if (s["label"] == label) return s["confidence"] as double;
    }
    return 0.0;
  }

  /// Return the rank (0-based) of a label, or -1 if not found.
  int rankOf(String label) {
    for (int i = 0; i < allScores.length; i++) {
      if (allScores[i]["label"] == label) return i;
    }
    return -1;
  }
}

// ── Classifier ────────────────────────────────────────────────────────────

class InjuryClassifier {
  Interpreter? _interpreter;
  late HFTokenizer _tokenizer;

  // Cache stores full ClassificationResult, not just the label string.
  final Map<String, ClassificationResult> _cache = {};
  static const int _maxCacheSize = 50;

  // ── Init ─────────────────────────────────────────────────────────────

  Future<void> loadModel() async {
    try {
      final data = await rootBundle.load('assets/model.tflite');
      debugPrint("✅ DistilBERT model loaded: ${data.lengthInBytes} bytes");

      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      _tokenizer =
          await HFTokenizer.fromAssets('assets/tokenizer.json', maxLen: 128);
      _interpreter!.allocateTensors();
      debugPrint("✅ Model and tokenizer ready");
      await _warmUp();
    } catch (e, stack) {
      debugPrint("❌ Error loading model: $e\nStack: $stack");
      _interpreter = null;
    }
  }

  Future<void> _warmUp() async {
    if (_interpreter == null) return;
    debugPrint("⏳ Warming up model...");
    await classifyFull("test warmup");
    debugPrint("✅ Model warmed up");
  }

  // ── Core: single inference, returns everything ────────────────────────

  /// THE one method that actually runs the TFLite model.
  /// All other methods call this and derive their answer from the result.
  /// Cached so repeated calls with the same text cost nothing.
  Future<ClassificationResult?> classifyFull(String text) async {
    if (_interpreter == null) {
      debugPrint("❌ Interpreter not initialised");
      return null;
    }

    final cacheKey = text.toLowerCase().trim();
    if (_cache.containsKey(cacheKey)) {
      debugPrint("✅ Cache hit: $cacheKey");
      return _cache[cacheKey];
    }

    try {
      final enc = _tokenizer.encode(text);
      final inputs = <Object>[
        [enc["attention_mask"]!],
        [enc["input_ids"]!],
      ];
      final outputs = <int, Object>{
        0: List.generate(1, (_) => List.filled(12, 0.0)),
      };

      final sw = Stopwatch()..start();
      _interpreter!.runForMultipleInputs(inputs, outputs);
      sw.stop();
      debugPrint("⏱️ Inference: ${sw.elapsedMilliseconds}ms");

      final raw    = (outputs[0] as List<List<double>>)[0];
      final probs  = _softmax(raw);

      // Build sorted list of all 12 classes.
      final allScores = List.generate(probs.length, (i) => {
        "label"     : injuryLabels[i] ?? "unknown_$i",
        "index"     : i,
        "confidence": probs[i],
      });
      allScores.sort((a, b) =>
          (b["confidence"] as double).compareTo(a["confidence"] as double));

      // Print all 12 scores to terminal for debugging.
      debugPrint("━━━ All 12 class scores ━━━");
      for (int i = 0; i < allScores.length; i++) {
        final s = allScores[i];
        final bar = "█" * ((s["confidence"] as double) * 30).round();
        debugPrint(
            "  ${(i + 1).toString().padLeft(2)}. "
            "${(s["label"] as String).padRight(20)} "
            "${((s["confidence"] as double) * 100).toStringAsFixed(2).padLeft(6)}%  $bar");
      }
debugPrint(
  "  Top-1: ${allScores[0]['label']}  "
  "${((allScores[0]['confidence'] as double) * 100).toStringAsFixed(1)}%  |  "
  "Top-2: ${allScores[1]['label']}  "
  "${((allScores[1]['confidence'] as double) * 100).toStringAsFixed(1)}%  |  "
  "Gap: ${(((allScores[0]['confidence'] as double) - (allScores[1]['confidence'] as double)) * 100).toStringAsFixed(1)}pp"
);

debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━");

final result = ClassificationResult(allScores);

      // Cache it.
      if (_cache.length >= _maxCacheSize) {
        _cache.remove(_cache.keys.first);
      }
      _cache[cacheKey] = result;

      return result;
    } catch (e, stack) {
      debugPrint("❌ classifyFull error: $e\nStack: $stack");
      return null;
    }
  }

  // ── Convenience wrappers (backward-compatible) ────────────────────────
  // These all call classifyFull() — no extra inference.

  Future<String> predict(String text) async {
    final result = await classifyFull(text);
    if (result == null) return "Model not loaded";
    if (result.top1Confidence >= 0.6) return result.top1Label;
    return "Please explain the situation in detail.";
  }

  Future<String> predictWithCache(String text) async => predict(text);

  Future<double> getConfidence(String text) async {
    final result = await classifyFull(text);
    return result?.top1Confidence ?? 0.0;
  }

  // ── Kept for any code that still calls getTopScores directly ─────────

  Future<List<Map<String, dynamic>>> getTopScores(String text) async {
    final result = await classifyFull(text);
    return result?.allScores ?? [];
  }

  // ── Kept for HybridIntentClassifier ───────────────────────────────────

  Future<Map<String, dynamic>> getAmbiguityInfo(String text) async {
    final result = await classifyFull(text);
    if (result == null) {
      return {
        "top1_label"      : "unknown",
        "top1_confidence" : 0.0,
        "top2_label"      : "unknown",
        "top2_confidence" : 0.0,
        "gap"             : 0.0,
        "all_scores"      : <Map<String, dynamic>>[],
        "result"          : null,
      };
    }
    return {
      "top1_label"      : result.top1Label,
      "top1_confidence" : result.top1Confidence,
      "top2_label"      : result.top2Label,
      "top2_confidence" : result.top2Confidence,
      "gap"             : result.gap,
      "all_scores"      : result.allScores,
      "result"          : result,   // pass the full object through
    };
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce(math.max);
    final exps     = logits.map((l) => math.exp(l - maxLogit)).toList();
    final sum      = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sum).toList();
  }

  void clearCache() {
    _cache.clear();
    debugPrint("🗑️ Cache cleared");
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}