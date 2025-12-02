import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder(); // ✅ Factory constructor

  /// Start recording audio to a unique file
  Future<String?> startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        log("Microphone permission denied");
        return null;
      }

      if (await _recorder.isRecording()) {
        log("Already recording");
        return null;
      }

      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${dir.path}/speech_$timestamp.m4a';

      // ✅ Pass RecordConfig as first positional argument
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 16000,
        ),
        path: filePath,
      );

      log("Recording started: $filePath");
      return filePath;
    } catch (e) {
      log("Recorder failed: $e");
      return null;
    }
  }

  /// Stop recording and return file path
  Future<String?> stopRecording() async {
    try {
      if (!await _recorder.isRecording()) {
        log("Recorder is not active");
        return null;
      }
      final path = await _recorder.stop();
      log("Recording stopped: $path");
      return path;
    } catch (e) {
      log("Stop recorder failed: $e");
      return null;
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _recorder.cancel();
      log("Recording cancelled");
    } catch (e) {
      log("Cancel failed: $e");
    }
  }

  Future<void> dispose() async {
    try {
      await _recorder.dispose();
      log("Recorder disposed");
    } catch (e) {
      log("Dispose failed: $e");
    }
  }

  Future<bool> get isRecording async => await _recorder.isRecording();
}
