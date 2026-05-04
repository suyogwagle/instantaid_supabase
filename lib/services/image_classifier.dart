import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ImageClassifier {
  late Interpreter _interpreter;
  bool _isModelLoaded = false;
  final double confidenceThreshold = 0.90;

  // Class order from training: ['burns', 'snakebites', 'wounds']
  final List<String> labels = [
    'burns',
    'snakebites',
    'wounds'
  ];

  final Map<String, String> labelMapping = {
    'burns': 'burn',
    'snakebites': 'snake_bite',
    'wounds': 'wound',
  };

  // Load the TFLite model
  Future<bool> loadModel({String assetPath = 'assets/injury_classifier.tflite'}) async {
    try {
      _interpreter = await Interpreter.fromAsset(assetPath);
      _isModelLoaded = true;
      print('✓ Image classifier loaded successfully');
      print('Input shape: ${_interpreter.getInputTensor(0).shape}');
      print('Output shape: ${_interpreter.getOutputTensor(0).shape}');
      return true;
    } catch (e) {
      print('❌ Error loading image classifier: $e');
      _isModelLoaded = false;
      return false;
    }
  }

  /// Main classification function
  Map<String, dynamic> classify(img.Image image) {
    if (!_isModelLoaded) {
      throw Exception('Model not loaded. Call loadModel() first.');
    }

    try {
      // Preprocess the image
      Float32List input = _preprocessImage(image);

      // Reshape input: [1, 224, 224, 3]
      var inputReshaped = input.reshape([1, 224, 224, 3]);

      // Prepare output buffer
      var output = List.filled(1 * labels.length, 0.0).reshape([1, labels.length]);

      // Run inference
      _interpreter.run(inputReshaped, output);

      // Get probabilities
      List<double> probabilities = output[0];

      // Find highest probability
      double maxConfidence = probabilities.reduce((a, b) => a > b ? a : b);
      int maxIndex = probabilities.indexOf(maxConfidence);

      // Create map of all probabilities
      Map<String, double> allProbabilities = {};
      for (int i = 0; i < labels.length; i++) {
        allProbabilities[labels[i]] = probabilities[i];
      }

      String predictedLabel = labels[maxIndex];
      String mappedLabel = labelMapping[predictedLabel] ?? predictedLabel;

      return {
        'label': mappedLabel,
        'confidence': maxConfidence,
        'allProbabilities': allProbabilities,
        'isConfident': maxConfidence >= confidenceThreshold,
      };
    } catch (e) {
      print('❌ Error during classification: $e');
      rethrow;
    }
  }
  // Add this after the classify function
  Map<String, dynamic> classifyDebug(img.Image image) {
    if (!_isModelLoaded) {
      throw Exception('Model not loaded');
    }

    var input = _preprocessImage(image);
    var inputReshaped = input.reshape([1, 224, 224, 3]);
    var output = List.filled(1 * labels.length, 0.0).reshape([1, labels.length]);

    _interpreter.run(inputReshaped, output);

    List<double> probabilities = output[0];

    print('\n🔍 RAW OUTPUT FROM TFLITE:');
    print('Raw values: $probabilities');
    print('Sum: ${probabilities.reduce((a, b) => a + b)}');

    for (int i = 0; i < labels.length; i++) {
      print('${labels[i]}: ${probabilities[i]}');
    }

    double maxConfidence = probabilities.reduce((a, b) => a > b ? a : b);
    int maxIndex = probabilities.indexOf(maxConfidence);

    String predictedLabel = labels[maxIndex];
    String mappedLabel = labelMapping[predictedLabel] ?? predictedLabel;

    return {
      'label': mappedLabel,
      'confidence': maxConfidence,
      'allProbabilities': Map.fromIterables(labels, probabilities),
      'isConfident': maxConfidence >= confidenceThreshold,
    };
  }

  void debugModelWeights() {
    if (!_isModelLoaded) {
      print('❌ Model not loaded');
      return;
    }

    print('🔍 Model interpreter: $_interpreter');
    print('🔍 Input shape: ${_interpreter.getInputTensor(0).shape}');
    print('🔍 Output shape: ${_interpreter.getOutputTensor(0).shape}');
  }


  /// Preprocess image: resize to 224x224, no normalization here. training mai gareko.
  Float32List _preprocessImage(img.Image image) {
    img.Image resized = img.copyResize(
      image,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.linear,
    );

    var input = Float32List(224 * 224 * 3);
    int pixelIndex = 0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        img.Pixel pixel = resized.getPixel(x, y);

        // Feed RAW 0-255 values.
        // The model's internal Rescaling layer will handle the math.
        input[pixelIndex++] = pixel.r.toDouble();
        input[pixelIndex++] = pixel.g.toDouble();
        input[pixelIndex++] = pixel.b.toDouble();
      }
    }
    return input;
  }


  /// Dispose the interpreter to free resources
  void dispose() {
    if (_isModelLoaded) {
      _interpreter.close();
      _isModelLoaded = false;
    }
  }
}