import 'package:flutter/material.dart';
import '../services/injury_classifier.dart';
import 'text_input_screen.dart';

class EmergencyModeScreen extends StatefulWidget {
  const EmergencyModeScreen({super.key});

  @override
  State<EmergencyModeScreen> createState() => _EmergencyModeScreenState();
}

class _EmergencyModeScreenState extends State<EmergencyModeScreen> {
  final classifier = InjuryClassifier();

  @override
  void initState() {
    super.initState();
    _initModel(); // call when the screen is created
  }

  Future<void> _initModel() async {
    try {
      debugPrint("Loading model...");
      await classifier.loadModel();
      debugPrint("Model loaded successfully");

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TextInputScreen(classifier: classifier),
        ),
      );
    } catch (e, stack) {
      debugPrint("Error loading model: $e");
      debugPrint("Stack trace: $stack");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load model: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
