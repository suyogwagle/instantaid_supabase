import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ImageClassifier {
  late Interpreter _interpreter;
  bool _isModelLoaded = false;

  // Class order from training: ['burn', 'healthy_human_limbs', 'snakebite', 'wound']
  final List<String> labels = [
    'burn',
    'healthy_human_limbs',
    'snakebite',
    'wound'
  ];

  // Load the TFLite model
  Future<bool> loadModel({String assetPath = 'assets/injury_classifier_quant.tflite'}) async {
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

      return {
        'label': labels[maxIndex],
        'confidence': maxConfidence,
        'allProbabilities': allProbabilities,
        'isConfident': maxConfidence >= 0.6,
      };
    } catch (e) {
      print('❌ Error during classification: $e');
      rethrow;
    }
  }
  // Add this after the classify function
  Map<String, dynamic> classifyDebug(img.Image image) {
    if (!_isModelLoaded) {
      throw Exception('Model not loaded. Call loadModel() first.');
    }

    try {
      var input = _preprocessImage(image);
      var inputReshaped = input.reshape([1, 224, 224, 3]);
      var output = List.filled(1 * labels.length, 0.0).reshape([1, labels.length]);

      _interpreter.run(inputReshaped, output);

      List<double> probabilities = output[0];

      // Print ALL probabilities for debugging
      print('\n🔍 DEBUG - All Class Probabilities:');
      for (int i = 0; i < labels.length; i++) {
        print('${labels[i]}: ${(probabilities[i] * 100).toStringAsFixed(2)}%');
      }

      double maxConfidence = probabilities.reduce((a, b) => a > b ? a : b);
      int maxIndex = probabilities.indexOf(maxConfidence);

      Map<String, double> allProbabilities = {};
      for (int i = 0; i < labels.length; i++) {
        allProbabilities[labels[i]] = probabilities[i];
      }

      return {
        'label': labels[maxIndex],
        'confidence': maxConfidence,
        'allProbabilities': allProbabilities,
        'isConfident': maxConfidence >= 0.6,
      };
    } catch (e) {
      print('❌ Error during classification: $e');
      rethrow;
    }
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


  /// Preprocess image: resize to 224x224, normalize [-1,1]
  Float32List _preprocessImage(img.Image image) {
    // Resize to 224x224 (match training preprocessing)
    img.Image resized = img.copyResize(
      image,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.linear,
    );

    // Prepare input buffer
    var input = Float32List(224 * 224 * 3);
    int pixelIndex = 0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        img.Pixel pixel = resized.getPixel(x, y);  // Returns Pixel object

        // Extract RGB channels (newer image package API)
        double r = pixel.r.toDouble();
        double g = pixel.g.toDouble();
        double b = pixel.b.toDouble();

        // Normalize for MobileNetV3
        input[pixelIndex++] = (r / 127.5) - 1.0;
        input[pixelIndex++] = (g / 127.5) - 1.0;
        input[pixelIndex++] = (b / 127.5) - 1.0;
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