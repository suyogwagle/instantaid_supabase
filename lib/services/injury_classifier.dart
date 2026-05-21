// lib/services/injury_classifier.dart

// KEY FIX:
// Every public method calls classifyFull() exactly ONCE.
// No duplicate TFLite inference runs.
// Includes full NLP pipeline timing/debug logging.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/labels.dart';
import 'tokenizer.dart';

// ─────────────────────────────────────────────────────────────
// RESULT OBJECT
// ─────────────────────────────────────────────────────────────

class ClassificationResult {
  /// Sorted descending by confidence.
  final List<Map<String, dynamic>> allScores;

  ClassificationResult(this.allScores);

  String get top1Label =>
      allScores[0]["label"] as String;

  double get top1Confidence =>
      allScores[0]["confidence"] as double;

  String get top2Label =>
      allScores.length > 1
          ? allScores[1]["label"] as String
          : top1Label;

  double get top2Confidence =>
      allScores.length > 1
          ? allScores[1]["confidence"] as double
          : 0.0;

  double get gap =>
      top1Confidence - top2Confidence;

  double confidenceOf(String label) {
    for (final s in allScores) {
      if (s["label"] == label) {
        return s["confidence"] as double;
      }
    }
    return 0.0;
  }

  int rankOf(String label) {
    for (int i = 0; i < allScores.length; i++) {
      if (allScores[i]["label"] == label) {
        return i;
      }
    }
    return -1;
  }
}

// ─────────────────────────────────────────────────────────────
// CLASSIFIER
// ─────────────────────────────────────────────────────────────

class InjuryClassifier {
  Interpreter? _interpreter;
  late HFTokenizer _tokenizer;

  final Map<String, ClassificationResult> _cache = {};

  static const int _maxCacheSize = 50;

  // ─────────────────────────────────────────────────────────
  // LOAD MODEL
  // ─────────────────────────────────────────────────────────

  Future<void> loadModel() async {
    try {
      final data =
          await rootBundle.load('assets/model.tflite');

      debugPrint(
        "✅ DistilBERT model loaded: "
        "${data.lengthInBytes} bytes",
      );

      _interpreter = await Interpreter.fromAsset(
        'assets/model.tflite',
      );

      _tokenizer = await HFTokenizer.fromAssets(
        'assets/tokenizer.json',
        maxLen: 128,
      );

      _interpreter!.allocateTensors();

      debugPrint("✅ Model and tokenizer ready");

      await _warmUp();
    } catch (e, stack) {
      debugPrint(
        "❌ Error loading model: $e\n$stack",
      );

      _interpreter = null;
    }
  }

  Future<void> _warmUp() async {
    if (_interpreter == null) return;

    debugPrint("⏳ Warming up NLP model...");

    await classifyFull("test warmup");

    debugPrint("✅ NLP model warmed up");
  }

  // ─────────────────────────────────────────────────────────
  // MAIN INFERENCE
  // ─────────────────────────────────────────────────────────

  Future<ClassificationResult?> classifyFull(
    String text,
  ) async {
    if (_interpreter == null) {
      debugPrint("❌ Interpreter not initialized");
      return null;
    }

    final cacheKey =
        text.toLowerCase().trim();

    // CACHE HIT
    if (_cache.containsKey(cacheKey)) {
      debugPrint("✅ Cache hit: $cacheKey");
      return _cache[cacheKey];
    }

    try {
      // ─────────────────────────────────────
      // TOTAL TIMER
      // ─────────────────────────────────────

      final totalWatch = Stopwatch()..start();

      // ─────────────────────────────────────
      // TOKENIZATION
      // ─────────────────────────────────────

      final tokenizeWatch = Stopwatch()..start();

      final enc = _tokenizer.encode(text);

      tokenizeWatch.stop();

      // ─────────────────────────────────────
      // INPUT BUILD
      // ─────────────────────────────────────

      final inputBuildWatch =
          Stopwatch()..start();

      final inputs = <Object>[
        [enc["attention_mask"]!],
        [enc["input_ids"]!],
      ];

      final outputs = <int, Object>{
        0: List.generate(
          1,
          (_) => List.filled(12, 0.0),
        ),
      };

      inputBuildWatch.stop();

      // ─────────────────────────────────────
      // INFERENCE
      // ─────────────────────────────────────

      final inferenceWatch =
          Stopwatch()..start();

      _interpreter!.runForMultipleInputs(
        inputs,
        outputs,
      );

      inferenceWatch.stop();

      // ─────────────────────────────────────
      // POSTPROCESS
      // ─────────────────────────────────────

      final postWatch = Stopwatch()..start();

      final raw =
          (outputs[0] as List<List<double>>)[0];

      final probs = _softmax(raw);

      postWatch.stop();

      totalWatch.stop();

      // ─────────────────────────────────────
      // BUILD SCORES
      // ─────────────────────────────────────

      final allScores = List.generate(
        probs.length,
        (i) => {
          "label":
              injuryLabels[i] ?? "unknown_$i",
          "index": i,
          "confidence": probs[i],
        },
      );

      allScores.sort(
        (a, b) => (b["confidence"] as double)
            .compareTo(
          a["confidence"] as double,
        ),
      );

      // ─────────────────────────────────────
      // DEBUG LOGGING
      // ─────────────────────────────────────

      debugPrint('\n🧠 NLP MODEL DEBUG');
      debugPrint(
          '────────────────────────────────');

      debugPrint(
        '📝 Input text: "$text"',
      );

      debugPrint(
        '🔍 NLP top-1: '
        '${allScores[0]['label']} '
        '${((allScores[0]['confidence']
                    as double) *
                100)
            .toStringAsFixed(1)}%',
      );

      debugPrint(
        '🔍 NLP top-2: '
        '${allScores[1]['label']} '
        '${((allScores[1]['confidence']
                    as double) *
                100)
            .toStringAsFixed(1)}%',
      );

      debugPrint(
        '📏 Confidence gap: '
        '${((((allScores[0]['confidence']
                            as double) -
                        (allScores[1]['confidence']
                            as double)) *
                    100))
                .toStringAsFixed(1)}pp',
      );

      // TIMINGS

      debugPrint(
        '⚡ Tokenization: '
        '${tokenizeWatch.elapsedMicroseconds / 1000}ms',
      );

      debugPrint(
        '⚡ Input build: '
        '${inputBuildWatch.elapsedMicroseconds / 1000}ms',
      );

      debugPrint(
        '⚡ TFLite inference: '
        '${inferenceWatch.elapsedMilliseconds}ms',
      );

      debugPrint(
        '⚡ Postprocess: '
        '${postWatch.elapsedMicroseconds / 1000}ms',
      );

      debugPrint(
        '⏱️ Total NLP pipeline: '
        '${totalWatch.elapsedMilliseconds}ms',
      );

      // ALL SCORES

      debugPrint(
        '📊 All class probabilities:',
      );

      for (int i = 0;
          i < allScores.length;
          i++) {
        final s = allScores[i];

        debugPrint(
          ' ${(i + 1).toString().padLeft(2)}. '
          '${(s["label"] as String).padRight(22)} '
          '${((s["confidence"] as double) * 100).toStringAsFixed(2).padLeft(6)}%',
        );
      }

      debugPrint(
          '────────────────────────────────\n');

      // ─────────────────────────────────────
      // CREATE RESULT
      // ─────────────────────────────────────

      final result =
          ClassificationResult(allScores);

      // ─────────────────────────────────────
      // CACHE RESULT
      // ─────────────────────────────────────

      if (_cache.length >= _maxCacheSize) {
        _cache.remove(_cache.keys.first);
      }

      _cache[cacheKey] = result;

      return result;
    } catch (e, stack) {
      debugPrint(
        "❌ classifyFull error: $e\n$stack",
      );

      return null;
    }
  }

  // ─────────────────────────────────────────────────────────
  // WRAPPERS
  // ─────────────────────────────────────────────────────────

  Future<String> predict(String text) async {
    final result = await classifyFull(text);

    if (result == null) {
      return "Model not loaded";
    }

    if (result.top1Confidence >= 0.6) {
      return result.top1Label;
    }

    return "Please explain the situation in detail.";
  }

  Future<String> predictWithCache(
    String text,
  ) async {
    return predict(text);
  }

  Future<double> getConfidence(
    String text,
  ) async {
    final result = await classifyFull(text);

    return result?.top1Confidence ?? 0.0;
  }

  Future<List<Map<String, dynamic>>>
      getTopScores(String text) async {
    final result = await classifyFull(text);

    return result?.allScores ?? [];
  }

  // ─────────────────────────────────────────────────────────
  // AMBIGUITY INFO
  // ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>>
      getAmbiguityInfo(String text) async {
    final result = await classifyFull(text);

    if (result == null) {
      return {
        "top1_label": "unknown",
        "top1_confidence": 0.0,
        "top2_label": "unknown",
        "top2_confidence": 0.0,
        "gap": 0.0,
        "all_scores": <Map<String, dynamic>>[],
        "result": null,
      };
    }

    return {
      "top1_label": result.top1Label,
      "top1_confidence":
          result.top1Confidence,
      "top2_label": result.top2Label,
      "top2_confidence":
          result.top2Confidence,
      "gap": result.gap,
      "all_scores": result.allScores,
      "result": result,
    };
  }

  // ─────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────

  List<double> _softmax(
    List<double> logits,
  ) {
    final maxLogit =
        logits.reduce(math.max);

    final exps = logits
        .map(
          (l) => math.exp(l - maxLogit),
        )
        .toList();

    final sum =
        exps.reduce((a, b) => a + b);

    return exps
        .map((e) => e / sum)
        .toList();
  }

  void clearCache() {
    _cache.clear();

    debugPrint("🧹 NLP cache cleared");
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}