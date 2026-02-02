import 'package:flutter/material.dart';
import 'package:instant_aid/services/injury_classifier.dart';
import 'package:instant_aid/services/hybrid_intent_classifier.dart';  // NEW IMPORT
import 'package:instant_aid/services/whisper_service.dart';
import 'package:instant_aid/emergency_page.dart';

class EmergencyLoaderScreen extends StatefulWidget {
  const EmergencyLoaderScreen({super.key});

  @override
  State<EmergencyLoaderScreen> createState() => _EmergencyLoaderScreenState();
}

class _EmergencyLoaderScreenState extends State<EmergencyLoaderScreen> {
  final classifier = InjuryClassifier();
  final whisper = WhisperService();
  late HybridIntentClassifier hybridClassifier;  // NEW

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    try {
      debugPrint("🔄 Loading AI models...");

      // Load injury classifier
      await classifier.loadModel();
      debugPrint("✅ InjuryClassifier loaded");

      // NEW: Initialize hybrid classifier
      hybridClassifier = HybridIntentClassifier(classifier);
      debugPrint("✅ HybridIntentClassifier ready");

      // WhisperService ready-to-use - no init needed

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmergencyModeScreen(
              classifier: classifier,
              hybridClassifier: hybridClassifier,  // NEW: Pass hybrid classifier
              whisper: whisper,
            ),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint("❌ Error loading models: $e");
      debugPrint("Stack trace: $stack");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load AI models: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_hospital, size: 80, color: Colors.white),
              SizedBox(height: 32),
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 24),
              Text(
                "Loading Emergency Assistant",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Enhanced NLP + Image Recognition",  // Updated text
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}