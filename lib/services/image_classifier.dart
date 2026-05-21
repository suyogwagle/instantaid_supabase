import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ImageClassifier {
  late Interpreter _interpreter;

  bool _isModelLoaded = false;

  final double confidenceThreshold = 0.90;

  // Class order from training
  final List<String> labels = [
    'burns',
    'snakebites',
    'wounds',
  ];

  final Map<String, String> labelMapping = {
    'burns': 'burn',
    'snakebites': 'snake_bite',
    'wounds': 'wound',
  };

  // ─────────────────────────────────────────────
  // LOAD MODEL
  // ─────────────────────────────────────────────

  Future<bool> loadModel({
    String assetPath = 'assets/injury_classifier.tflite',
  }) async {
    try {
      _interpreter = await Interpreter.fromAsset(
        assetPath,
      );

      _isModelLoaded = true;

      print('✓ Image classifier loaded successfully');

      print(
        'Input shape: '
        '${_interpreter.getInputTensor(0).shape}',
      );

      print(
        'Output shape: '
        '${_interpreter.getOutputTensor(0).shape}',
      );

      return true;
    } catch (e) {
      print(
        '❌ Error loading image classifier: $e',
      );

      _isModelLoaded = false;

      return false;
    }
  }

  // ─────────────────────────────────────────────
  // MAIN CLASSIFICATION
  // ─────────────────────────────────────────────

  Map<String, dynamic> classify(
    img.Image image,
  ) {
    if (!_isModelLoaded) {
      throw Exception(
        'Model not loaded. Call loadModel() first.',
      );
    }

    try {
      Float32List input =
          _preprocessImage(image);

      var inputReshaped = input.reshape([
        1,
        224,
        224,
        3,
      ]);

      var output = List.generate(
        1,
        (_) => List.filled(labels.length, 0.0),
      );

      _interpreter.run(
        inputReshaped,
        output,
      );

      List<double> probabilities =
          List<double>.from(output[0]);

      double maxConfidence =
          probabilities.reduce(
        (a, b) => a > b ? a : b,
      );

      int maxIndex =
          probabilities.indexOf(maxConfidence);

      Map<String, double>
          allProbabilities = {};

      for (
        int i = 0;
        i < labels.length;
        i++
      ) {
        allProbabilities[labels[i]] =
            probabilities[i];
      }

      String predictedLabel =
          labels[maxIndex];

      String mappedLabel =
          labelMapping[predictedLabel] ??
              predictedLabel;

      return {
        'label': mappedLabel,
        'confidence': maxConfidence,
        'allProbabilities':
            allProbabilities,
        'isConfident':
            maxConfidence >=
                confidenceThreshold,
      };
    } catch (e) {
      print(
        '❌ Error during classification: $e',
      );

      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // DEBUG CLASSIFICATION WITH TIMINGS
  // ─────────────────────────────────────────────

  Map<String, dynamic> classifyDebug(
    img.Image image,
  ) {
    if (!_isModelLoaded) {
      throw Exception('Model not loaded');
    }

    // TOTAL TIMER
    final totalWatch =
        Stopwatch()..start();

    // PREPROCESS TIMER
    final preprocessWatch =
        Stopwatch()..start();

    var input =
        _preprocessImage(image);

    preprocessWatch.stop();

    // Input reshape
    var inputReshaped = input.reshape([
      1,
      224,
      224,
      3,
    ]);

    // Output buffer
    var output = List.generate(
      1,
      (_) => List.filled(
        labels.length,
        0.0,
      ),
    );

    // INFERENCE TIMER
    final inferenceWatch =
        Stopwatch()..start();

    _interpreter.run(
      inputReshaped,
      output,
    );

    inferenceWatch.stop();

    // POSTPROCESS TIMER
    final postWatch =
        Stopwatch()..start();

    List<double> probabilities =
        List<double>.from(output[0]);

    double maxConfidence =
        probabilities.reduce(
      (a, b) => a > b ? a : b,
    );

    int maxIndex =
        probabilities.indexOf(
      maxConfidence,
    );

    String predictedLabel =
        labels[maxIndex];

    String mappedLabel =
        labelMapping[
              predictedLabel
            ] ??
            predictedLabel;

    // Create probability map
    Map<String, double>
        probabilityMap = {};

    for (
      int i = 0;
      i < labels.length;
      i++
    ) {
      probabilityMap[labels[i]] =
          probabilities[i];
    }

    // Sort predictions
    final sortedPredictions =
        probabilityMap.entries.toList()
          ..sort(
            (a, b) => b.value.compareTo(
              a.value,
            ),
          );

    final top1 =
        sortedPredictions[0];

    final top2 =
        sortedPredictions.length > 1
            ? sortedPredictions[1]
            : null;

    postWatch.stop();

    totalWatch.stop();

    // DEBUG LOGS

    print(
      '\n🖼️ IMAGE MODEL DEBUG',
    );

    print(
      '────────────────────────',
    );

    print(
      '🔍 Image top-1: '
      '${top1.key} '
      '${(top1.value * 100).toStringAsFixed(1)}%',
    );

    if (top2 != null) {
      print(
        '🔍 Image top-2: '
        '${top2.key} '
        '${(top2.value * 100).toStringAsFixed(1)}%',
      );
    }

    print(
      '📊 All probs: '
      '$probabilityMap',
    );

    print(
      '⚡ Preprocess: '
      '${preprocessWatch.elapsedMilliseconds}ms',
    );

    print(
      '⚡ TFLite inference: '
      '${inferenceWatch.elapsedMilliseconds}ms',
    );

    print(
      '⚡ Postprocess: '
      '${postWatch.elapsedMilliseconds}ms',
    );

    print(
      '⏱️ Total image pipeline: '
      '${totalWatch.elapsedMilliseconds}ms',
    );

    print(
      '────────────────────────\n',
    );

    return {
      'label': mappedLabel,
      'confidence': maxConfidence,
      'allProbabilities':
          probabilityMap,
      'isConfident':
          maxConfidence >=
              confidenceThreshold,

      'preprocess_ms':
          preprocessWatch
              .elapsedMilliseconds,

      'inference_ms':
          inferenceWatch
              .elapsedMilliseconds,

      'postprocess_ms':
          postWatch
              .elapsedMilliseconds,

      'total_ms':
          totalWatch
              .elapsedMilliseconds,
    };
  }

  // ─────────────────────────────────────────────
  // DEBUG MODEL INFO
  // ─────────────────────────────────────────────

  void debugModelWeights() {
    if (!_isModelLoaded) {
      print('❌ Model not loaded');
      return;
    }

    print(
      '🔍 Model interpreter: '
      '$_interpreter',
    );

    print(
      '🔍 Input shape: '
      '${_interpreter.getInputTensor(0).shape}',
    );

    print(
      '🔍 Output shape: '
      '${_interpreter.getOutputTensor(0).shape}',
    );
  }

  // ─────────────────────────────────────────────
  // IMAGE PREPROCESSING
  // ─────────────────────────────────────────────

  Float32List _preprocessImage(
    img.Image image,
  ) {
    img.Image resized =
        img.copyResize(
      image,
      width: 224,
      height: 224,
      interpolation:
          img.Interpolation.linear,
    );

    var input = Float32List(
      224 * 224 * 3,
    );

    int pixelIndex = 0;

    for (int y = 0; y < 224; y++) {
      for (
        int x = 0;
        x < 224;
        x++
      ) {
        img.Pixel pixel =
            resized.getPixel(x, y);

        // RAW 0-255 values
        // model's internal rescaling layer handles normalization

        input[pixelIndex++] =
            pixel.r.toDouble();

        input[pixelIndex++] =
            pixel.g.toDouble();

        input[pixelIndex++] =
            pixel.b.toDouble();
      }
    }

    return input;
  }

  // ─────────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────────

  void dispose() {
    if (_isModelLoaded) {
      _interpreter.close();

      _isModelLoaded = false;
    }
  }
}