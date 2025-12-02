import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/labels.dart'; // injuryLabels: Map<int,String>
import 'tokenizer.dart';       // HFTokenizer implementation

class InjuryClassifier {
  Interpreter? _interpreter;
  late HFTokenizer _tokenizer;

  /// Load the DistilBERT TFLite model and tokenizer
  Future<void> loadModel() async {
    try {
      // Load model asset
      final data = await rootBundle.load('assets/model.tflite');
      debugPrint("DistilBERT model asset loaded: ${data.lengthInBytes} bytes");

      _interpreter = await Interpreter.fromAsset('assets/model.tflite');

      // Load tokenizer.json (exported from DistilBERT training)
      _tokenizer = await HFTokenizer.fromAssets('assets/tokenizer.json', maxLen: 128);

      _interpreter!.allocateTensors();
      debugPrint(" DistilBERT model and tokenizer loaded successfully");
    } catch (e, stack) {
      debugPrint("❌ Error loading DistilBERT model: $e");
      debugPrint("Stack trace: $stack");
      _interpreter = null;
    }
  }

  /// Softmax helper
  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce(math.max);
    final exps = logits.map((l) => math.exp(l - maxLogit)).toList();
    final sum = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sum).toList();
  }

  /// Predict injury label from text
  Future<String> predict(String text) async {
    if (_interpreter == null) {
      debugPrint(" Interpreter not initialized");
      return "Model not loaded";
    }

    try {
      final enc = _tokenizer.encode(text);

      // DistilBERT signature: 2 inputs [attention_mask, input_ids]
      final inputs = <Object>[
        [enc["attention_mask"]!],
        [enc["input_ids"]!],
      ];

      // Outputs: shape [1,12]
      final outputs = <int, Object>{
        0: List.generate(1, (_) => List.filled(12, 0.0)),
      };

      _interpreter!.runForMultipleInputs(inputs, outputs);

      final scores2d = outputs[0] as List<List<double>>;
      final scores = scores2d[0];

      final probs = _softmax(scores);
      final predIdx = probs.indexOf(probs.reduce(math.max));
      final confidence = probs[predIdx];

      debugPrint("Logits: $scores");
      debugPrint("Probs: $probs");
      debugPrint("Predicted class index: $predIdx");
      debugPrint("Confidence: $confidence");

      if (confidence >= 0.6) {
      return injuryLabels[predIdx] ?? "Unknown";
    } else {
      return "Please explain the situation in detail.";
    }
    } catch (e, stack) {
      debugPrint(" Error during prediction: $e");
      debugPrint("Stack trace: $stack");
      return "Prediction failed";
    }
  }
}
