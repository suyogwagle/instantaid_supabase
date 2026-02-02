import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/labels.dart';
import 'tokenizer.dart';

class InjuryClassifier {
  Interpreter? _interpreter;
  late HFTokenizer _tokenizer;

  // Prediction cache for performance
  final Map<String, String> _predictionCache = {};
  static const int maxCacheSize = 50;

  /// Load model and tokenizer
  Future<void> loadModel() async {
    try {
      final data = await rootBundle.load('assets/model.tflite');
      debugPrint("✅ DistilBERT model loaded: ${data.lengthInBytes} bytes");

      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      _tokenizer = await HFTokenizer.fromAssets('assets/tokenizer.json', maxLen: 128);
      _interpreter!.allocateTensors();

      debugPrint("✅ Model and tokenizer ready");

      // Warm up model
      await warmUp();
    } catch (e, stack) {
      debugPrint("❌ Error loading model: $e");
      debugPrint("Stack: $stack");
      _interpreter = null;
    }
  }

  /// Warm up model (reduces first prediction latency)
  Future<void> warmUp() async {
    if (_interpreter == null) return;

    debugPrint(" Warming up model...");
    await predict("test warmup");
    debugPrint("✅ Model warmed up");
  }

  /// Softmax helper
  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce(math.max);
    final exps = logits.map((l) => math.exp(l - maxLogit)).toList();
    final sum = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sum).toList();
  }

  /// Predict with caching
  Future<String> predictWithCache(String text) async {
    // Normalize text for cache key
    final cacheKey = text.toLowerCase().trim();

    // Check cache
    if (_predictionCache.containsKey(cacheKey)) {
      debugPrint("✅ Cache hit");
      return _predictionCache[cacheKey]!;
    }

    // Run prediction
    final result = await predict(text);

    // Cache result
    if (_predictionCache.length >= maxCacheSize) {
      _predictionCache.remove(_predictionCache.keys.first);
    }
    _predictionCache[cacheKey] = result;

    return result;
  }

  /// Main prediction method
  Future<String> predict(String text) async {
    if (_interpreter == null) {
      debugPrint("❌ Interpreter not initialized");
      return "Model not loaded";
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

      final stopwatch = Stopwatch()..start();
      _interpreter!.runForMultipleInputs(inputs, outputs);
      stopwatch.stop();
      debugPrint("⏱️ Inference: ${stopwatch.elapsedMilliseconds}ms");

      final scores2d = outputs[0] as List<List<double>>;
      final scores = scores2d[0];

      final probs = _softmax(scores);
      final predIdx = probs.indexOf(probs.reduce(math.max));
      final confidence = probs[predIdx];

      debugPrint("📊 Predicted: index=$predIdx, confidence=${(confidence * 100).toStringAsFixed(1)}%");

      if (confidence >= 0.6) {
        return injuryLabels[predIdx] ?? "Unknown";
      } else {
        return "Please explain the situation in detail.";
      }
    } catch (e, stack) {
      debugPrint("❌ Prediction error: $e");
      debugPrint("Stack: $stack");
      return "Prediction failed";
    }
  }
  /// This is what the hybrid classifier calls to get real ML confidence
  Future<double> getConfidence(String text) async {
    if (_interpreter == null) {
      debugPrint("❌ Interpreter not initialized for confidence");
      return 0.0;
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

      _interpreter!.runForMultipleInputs(inputs, outputs);

      final scores2d = outputs[0] as List<List<double>>;
      final scores = scores2d[0];
      final probs = _softmax(scores);
      final maxConfidence = probs.reduce(math.max);

      debugPrint("📊 getConfidence() returned: ${(maxConfidence * 100).toStringAsFixed(1)}%");

      return maxConfidence;
    } catch (e) {
      debugPrint("❌ Confidence calculation error: $e");
      return 0.0;
    }
  }

  /// Clear cache (call when memory is low)
  void clearCache() {
    _predictionCache.clear();
    debugPrint("🗑️ Prediction cache cleared");
  }

  /// Dispose interpreter
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}