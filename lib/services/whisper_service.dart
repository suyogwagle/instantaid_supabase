import 'package:flutter/material.dart';
import 'package:whisper_ggml/whisper_ggml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';

class WhisperService {
  final WhisperController _controller = WhisperController();
  final WhisperModel _model = WhisperModel.base;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initModel() async {
    if (_initialized) return;

    try {
      final bytesBase = await rootBundle.load('assets/ggml-${_model.modelName}.bin');
      final modelPathBase = await _controller.getPath(_model);
      final fileBase = File(modelPathBase);

      if (!fileBase.existsSync()) {
        await fileBase.writeAsBytes(
          bytesBase.buffer.asUint8List(bytesBase.offsetInBytes, bytesBase.lengthInBytes),
        );
      }

      debugPrint("Whisper model initialized offline at $modelPathBase");
      _initialized = true;
    } catch (e) {
      debugPrint("Offline model load failed, downloading instead: $e");
      await _controller.downloadModel(_model);
      _initialized = true;
    }
  }

  Future<String?> transcribe(String audioPath) async {
    try {
      final result = await _controller.transcribe(
        model: _model,
        audioPath: audioPath,
        lang: 'en',
      );
      return result?.transcription.text;
    } catch (e) {
      debugPrint("Transcription failed: $e");
      return null;
    }
  }
}
