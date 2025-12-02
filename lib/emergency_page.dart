import 'package:flutter/material.dart';
import 'package:instant_aid/services/injury_classifier.dart';
import 'package:instant_aid/services/audio_service.dart';
import 'package:instant_aid/services/whisper_service.dart';
import 'package:permission_handler/permission_handler.dart';

class EmergencyModeScreen extends StatefulWidget {
  final InjuryClassifier classifier;
  final WhisperService whisper;   // whisper

  const EmergencyModeScreen({
    super.key,
    required this.classifier,
    required this.whisper,
  });

  @override
  State<EmergencyModeScreen> createState() => _EmergencyModeScreenState();
}

class _EmergencyModeScreenState extends State<EmergencyModeScreen> {
  final TextEditingController controller = TextEditingController();
  final AudioService audio = AudioService();

  List<Map<String, dynamic>> messages = [];
  String? audioPath;

  InjuryClassifier get classifier => widget.classifier;
  WhisperService get whisper => widget.whisper;   //  injected whisper

  void sendMessage([String? textOverride]) async {
    final text = (textOverride ?? controller.text).trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"text": text, "isUser": true});
    });
    controller.clear();

    final result = await classifier.predict(text);

    setState(() {
      messages.add({
        "text": "Detected emergency: $result",
        "isUser": false,
      });
    });
  }

  Future<void> startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      setState(() {
        messages.add({
          "text": "⚠️ Microphone permission denied. Please enable it in Settings.",
          "isUser": false,
        });
      });
      openAppSettings();
      return;
    }

    audioPath = await audio.startRecording();
    if (audioPath == null) {
      setState(() {
        messages.add({
          "text": "⚠️ Microphone not available.",
          "isUser": false,
        });
      });
      return;
    }

    setState(() {
      messages.add({"text": "🎙 Recording started...", "isUser": false});
    });

    // Auto stop after 5 seconds
    Future.delayed(const Duration(seconds: 5), () async {
      await stopRecordingAndTranscribe();
      audioPath = null;
    });
  }

  Future<void> stopRecordingAndTranscribe() async {
    await audio.stopRecording();
    if (audioPath != null) {
      final transcription = await whisper.transcribe(audioPath!);
      if (transcription != null && transcription.isNotEmpty) {
        sendMessage(transcription);
      } else {
        setState(() {
          messages.add({
            "text": "⚠️ No speech detected or transcription failed.",
            "isUser": false,
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Assistant")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final msg = messages[i];
                return Align(
                  alignment: msg["isUser"]
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: msg["isUser"] ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color: msg["isUser"] ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Describe symptoms...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: startRecording,
                  icon: const Icon(Icons.mic),
                ),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
