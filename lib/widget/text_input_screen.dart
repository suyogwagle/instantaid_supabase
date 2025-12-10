import 'package:flutter/material.dart';
import '../../services/injury_classifier.dart';

class TextInputScreen extends StatefulWidget {
  final InjuryClassifier classifier;
  const TextInputScreen({super.key, required this.classifier});

  @override
  State<TextInputScreen> createState() => _TextInputScreenState();
}

class _TextInputScreenState extends State<TextInputScreen> {
  final controller = TextEditingController();
  String result = "";

  Future<void> _classify() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    final label = await widget.classifier.predict(text);
    setState(() => result = label);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Describe Your Injury")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Enter symptoms...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _classify,
              child: const Text("Predict"),
            ),
            const SizedBox(height: 20),
            Text(
              result.isEmpty ? "" : "Prediction: $result",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
