
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../services/audio_service.dart';
import '../services/whisper_service.dart';
import '../services/injury_classifier.dart';
import '../services/hybrid_intent_classifier.dart';  // NEW IMPORT
import '../services/image_classifier.dart';
import '../services/dialogue_manager.dart';
import '../services/emergency_severity.dart';  // NEW IMPORT
import '../services/confidence_system.dart';  // NEW IMPORT
import '../services/tts_service.dart';
import '../data/emergency_guidelines.dart';
import '../data/emergency_guidelines_np.dart';

class EmergencyModeScreen extends StatefulWidget {
  final InjuryClassifier classifier;
  final HybridIntentClassifier hybridClassifier;  // NEW
  final WhisperService whisper;

  const EmergencyModeScreen({
    super.key,
    required this.classifier,
    required this.hybridClassifier,  // NEW
    required this.whisper,
  });

  @override
  State<EmergencyModeScreen> createState() => _EmergencyModeScreenState();
}

class _EmergencyModeScreenState extends State<EmergencyModeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final AudioService _audioService = AudioService();
  final ImageClassifier _imageClassifier = ImageClassifier();
  final ImagePicker _imagePicker = ImagePicker();
  late DialogueManager _dialogueManager;
  late TtsService _ttsService;
  final List<Map<String, dynamic>> _messages = [];
  bool _isRecording = false;
  final bool _modelLoaded = true;
  bool _imageModelLoaded = false;
  bool _ttsEnabled = false;
  bool _isTtsSpeaking = false;
  bool _isProcessingImage = false;
  bool _isProcessingText = false;  // NEW: Track text processing
  late AnimationController _ttsAnimationController;

  @override
  void initState() {
    super.initState();
    _ttsEnabled = false;
    _isTtsSpeaking = false;
    _dialogueManager = DialogueManager(
      emergencyGuidelines,
      emergencyGuidelinesNp,
    );
    _ttsService = TtsService();
    _ttsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _initServices();
    _welcomeUser();
  }

  Future<void> _initServices() async {
    await _ttsService.init();
    _imageClassifier.loadModel().then((success) {
      setState(() => _imageModelLoaded = success);
      if (success) {
        debugPrint('✅ Image classifier loaded');
      }
    });
  }

  void _welcomeUser() {
    _addBotMessage(
      "👋 Welcome to Emergency First Aid Assistant.\n\n"
          "🔹 Describe the emergency in text\n"
          "🔹 Use voice input (mic button)\n"
          "🔹 Send an image of the injury\n\n"
          "I'll provide step-by-step first aid guidance.",
      "intro",
    );
  }

  void _addUserMessage(String text, {File? image}) {
    setState(() {
      _messages.add({
        "text": text,
        "isUser": true,
        "image": image,
        "timestamp": DateTime.now(),
      });
    });
  }

  void _addBotMessage(String text, String type) {
    setState(() {
      _messages.add({
        "text": text,
        "isUser": false,
        "type": type,
        "timestamp": DateTime.now(),
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_ttsEnabled &&
          (type == "steps" || type == "warning" || type == "question")) {
        _speakBotMessage(text);
      }
    });
  }

  Future<void> _speakBotMessage(String text) async {
    if (!_ttsEnabled) return;
    await _ttsService.speak(text);
    setState(() {
      _isTtsSpeaking = _ttsService.isSpeaking;
    });
    if (_isTtsSpeaking) {
      _ttsAnimationController.repeat(reverse: true);
    } else {
      _ttsAnimationController.stop();
      _ttsAnimationController.reset();
    }
  }

  Future<void> _toggleTts() async {
    setState(() {
      _ttsEnabled = !_ttsEnabled;
      if (!_ttsEnabled) {
        _isTtsSpeaking = false;
        _ttsAnimationController.stop();
        _ttsAnimationController.reset();
      }
    });
    if (_ttsEnabled) {
      final lastBotMessage = _messages.isNotEmpty
          ? _messages.lastWhere(
            (msg) => !msg["isUser"],
        orElse: () => {"text": ""},
      )
          : {"text": ""};
      await _speakBotMessage(lastBotMessage["text"] as String);
    } else {
      await _ttsService.stop();
    }
  }



  // Image classification (keep mostly same, minor tweaks)
  Future<void> _pickAndClassifyImage(ImageSource source) async {
    if (!_imageModelLoaded) {
      _addBotMessage("⚠️ Image classifier not loaded yet. Please wait...", "warning");
      return;
    }

    try {
      setState(() => _isProcessingImage = true);

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() => _isProcessingImage = false);
        return;
      }

      final imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes();
      img.Image? decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        _addBotMessage("⚠️ Failed to process image. Try another one.", "warning");
        setState(() => _isProcessingImage = false);
        return;
      }

      final result = _imageClassifier.classifyDebug(decodedImage);
      debugPrint('📸 Classification: ${result['label']}, Confidence: ${result['confidence']}');

      _addUserMessage("📷 Sent an image", image: imageFile);

      final label = result['label'] as String;
      final confidence = result['confidence'] as double;
      final isConfident = result['isConfident'] as bool;

      if (isConfident) {
        final intent = _mapImageLabelToIntent(label);

        if (intent == null ) {
          _addBotMessage(
            "✅ Image Analysis:\nDetected: ${label.replaceAll('_', ' ').toUpperCase()}\n"
                "Confidence: ${(confidence * 100).toStringAsFixed(1)}%\n\n"
                "I couldn't classify this injury type. Please:\n"
                "• Describe the injury in text, or\n"
                "• Send a clearer, well-lit image focusing on the injury",
            "warning",
          );
        } else {
          _addBotMessage(
            "📸 Image Analysis:\nDetected: ${label.replaceAll('_', ' ').toUpperCase()}\n"
                "Confidence: ${(confidence * 100).toStringAsFixed(1)}%\n\n"
                "Starting first aid guidance...",
            "intro",
          );

          // Start dialogue with intent from image
          _dialogueManager.reset();
          _dialogueManager.setIntentConfidence(confidence);  // NEW: Set confidence
          final responses = _dialogueManager.start(
            intent,
            userText: intent,
            intentConfidence: confidence,  // NEW: Pass confidence
          );
          for (final msg in responses) {
            _addBotMessage(msg, _getMessageType(msg));
          }
        }
      } else {
        _addBotMessage(
          "⚠️ Low confidence detection.\n"
              "Please:\n• Ensure good lighting\n• Focus on the injury\n• Retake with clearer view\n\n"
              "Or describe the injury in text.",
          "warning",
        );
      }

      setState(() => _isProcessingImage = false);
    } catch (e) {
      _addBotMessage("❌ Error processing image: $e", "warning");
      setState(() => _isProcessingImage = false);
    }
  }

  String? _mapImageLabelToIntent(String imageLabel) {
    // Directly return if it exists in guidelines
    if (emergencyGuidelines.containsKey(imageLabel)) {
      return imageLabel;
    }
    return null;
  }

  // NEW: Enhanced text message handling with hybrid classifier
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || !_modelLoaded) return;

    _addUserMessage(text);
    await _ttsService.stop();
    setState(() => _isProcessingText = true);

    try {
      // Check if user wants to reset
      if (_dialogueManager.isConversationComplete() ||
          text.toLowerCase().contains("new") ||
          text.toLowerCase().contains("another") ||
          text.toLowerCase().contains("नयाँ")) {
        _dialogueManager.reset();
        _addBotMessage("🔄 Starting new emergency assessment...", "intro");

        // Classify new intent using HYBRID approach
        await _handleNewEmergency(text);
        setState(() => _isProcessingText = false);
        return;
      }

      // If no intent yet, classify using HYBRID approach
      if (!_dialogueManager.hasIntent) {
        await _handleNewEmergency(text);
        setState(() => _isProcessingText = false);
        return;
      }

      // Continue existing conversation
      final responses = _dialogueManager.next(text);

      // NEW: Check if response is asking for clarification
      if (responses.length == 1 &&
          (responses[0].contains("more detail") ||
              responses[0].contains("थप विवरण"))) {
        _addBotMessage(responses[0], "question");
      } else {
        for (final msg in responses) {
          final type = _getMessageType(msg);
          _addBotMessage(msg, type);
        }
      }

    } catch (e, stack) {
      debugPrint("❌ Error processing message: $e");
      debugPrint("Stack: $stack");
      _addBotMessage("❌ Error processing your message. Please try again.", "warning");
    } finally {
      setState(() => _isProcessingText = false);
    }
  }

  // DEBUGGING HELPER
// Add this method to your _EmergencyModeScreenState class
// to see detailed confidence info in your UI

  //NEW: Add this method to display confidence breakdown for debugging
  // Replace your _showConfidenceDebug() method in emergency_page.dart with this:

  void _showConfidenceDebug(Map<String, dynamic> intentResult) {
    final method = intentResult["method"] as String;
    final confidence = intentResult["confidence"] as double;
    final mlConf = intentResult["ml_confidence"] as double?;
    final kwConf = intentResult["keyword_confidence"] as double?;

    String debugMsg = "🔍 Classification Debug:\n\n";
    debugMsg += "Method: $method\n";

    // Show individual confidences if both exist
    if (mlConf != null && kwConf != null) {
      debugMsg += "ML Confidence: ${(mlConf * 100).toStringAsFixed(1)}%\n";
      debugMsg += "Keyword Confidence: ${(kwConf * 100).toStringAsFixed(1)}%\n";
      debugMsg += "────────────────\n";
      debugMsg += "Using MAX: ${(confidence * 100).toStringAsFixed(1)}% ✅\n";
    } else if (mlConf != null) {
      debugMsg += "ML Confidence: ${(mlConf * 100).toStringAsFixed(1)}%\n";
    } else if (kwConf != null) {
      debugMsg += "Keyword Confidence: ${(kwConf * 100).toStringAsFixed(1)}%\n";
    } else {
      debugMsg += "Final Confidence: ${(confidence * 100).toStringAsFixed(1)}%\n";
    }

    debugMsg += "\nIntent: ${intentResult['intent']}";

    _addBotMessage(debugMsg, "info");
  }

// Then in _handleNewEmergency(), after getting intentResult, add:
// _showConfidenceDebug(intentResult);  // TEMPORARY - for debugging

// Example usage in _handleNewEmergency():
  // Replace your _handleNewEmergency() method in emergency_page.dart with this:

  Future<void> _handleNewEmergency(String text) async {
    final isNepali = _isNepali(text);

    // STEP 1: Use hybrid classifier (keywords + ML)
    debugPrint("🔍 Classifying intent with hybrid approach...");
    final intentResult = await widget.hybridClassifier.classifyIntent(text);

    final intent = intentResult["intent"] as String;
    final confidence = intentResult["confidence"] as double;
    final method = intentResult["method"] as String;

    debugPrint("✅ Intent: $intent (confidence: ${(confidence * 100).toStringAsFixed(1)}%, method: $method)");

    // TEMPORARY DEBUG - Comment out when done testing
    _showConfidenceDebug(intentResult);

    // STEP 2: Check if need disambiguation
    if (confidence < 0.5) {
      final disambigMsg = widget.hybridClassifier.getDisambiguationMessage(
        intentResult,
        isNepali: isNepali,
      );

      if (disambigMsg.isNotEmpty) {
        _addBotMessage(disambigMsg, "question");
        return;
      }
    }

    // STEP 3: Check for immediate critical emergency
    if (EnhancedCriticalDetector.requiresImmediateEmergencyCall(text)) {
      _addBotMessage(
        isNepali
            ? "🚨 गम्भीर आपतकालीन अवस्था!\nतुरुन्त 102/103 मा फोन गर्नुहोस्!"
            : "🚨 CRITICAL EMERGENCY!\nCALL 102/103 IMMEDIATELY!",
        "critical",
      );
    }

    // STEP 4: Handle unknown intent
    if (intent == "unknown" || intent.isEmpty) {
      _addBotMessage(
        isNepali
            ? "मलाई बुझिएन। के तपाईं थप विवरण दिन सक्नुहुन्छ?\n\n"
            "उदाहरण: 'सर्पले टोकेको', 'हात जलेको', 'घाउ लागेको'"
            : "I couldn't understand. Could you provide more details?\n\n"
            "Examples: 'snake bite', 'burned hand', 'deep cut'",
        "question",
      );
      return;
    }

    // STEP 5: IMPORTANT - Set confidence BEFORE starting dialogue
    // This ensures it's available even if dialogue completes immediately
    _dialogueManager.reset();
    _dialogueManager.setIntentConfidence(confidence);  // ✅ SET CONFIDENCE FIRST

    // STEP 6: Start dialogue with detected intent
    final responses = _dialogueManager.start(
      intent,
      userText: text,
      intentConfidence: confidence,  // Pass it here too for redundancy
    );

    // STEP 7: Display responses
    for (final msg in responses) {
      final type = _getMessageType(msg);
      _addBotMessage(msg, type);
    }

    // STEP 8: Show confidence info for transparency (optional)
    if (confidence < 0.7) {
      _addBotMessage(
        isNepali
            ? "ℹ️ नोट: मलाई पूर्ण रूपमा पक्का छैन। यदि गलत लाग्यो भने 'नयाँ' भन्नुहोस्।"
            : "ℹ️ Note: I'm not completely certain. If this seems wrong, say 'new emergency'.",
        "info",
      );
    }
  }

  // NEW: Helper to determine message type
  String _getMessageType(String msg) {
    if (msg.contains("CRITICAL") || msg.contains("गम्भीर")) {
      return "critical";
    }
    if (msg.contains("FIRST AID") || msg.contains("IMMEDIATE ACTION") ||
        msg.contains("तुरुन्त गर्नुपर्ने")) {
      return "steps";
    }
    if (msg.contains("⚠️") || msg.contains("WARNING")) {
      return "warning";
    }
    if (msg.contains("?") || msg.contains("के")) {
      return "question";
    }
    return "intro";
  }

  bool _isNepali(String text) {
    return RegExp(r"[अ-ह]").hasMatch(text) ||
        text.contains("हो") ||
        text.contains("होइन") ||
        text.contains("थाहा छैन");
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioService.stopRecording();
      setState(() => _isRecording = false);
      if (path != null) {
        final text = await widget.whisper.transcribe(path);
        if (text != null) await _sendMessage(text);
      }
    } else {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        _addBotMessage("⚠️ Microphone permission denied.", "warning");
        return;
      }
      await _audioService.startRecording();
      setState(() => _isRecording = true);
    }
  }

  Color _bubbleColor(String? type, bool isUser) {
    if (isUser) return Colors.red.shade400;
    return switch (type) {
      "intro" => Colors.blue.shade100,
      "question" => Colors.orange.shade100,
      "warning" => Colors.red.shade100,
      "critical" => Colors.red.shade700,  // NEW: Critical messages
      "info" => Colors.grey.shade300,     // NEW: Info messages
      _ => Colors.grey.shade200,
    };
  }

  Widget _buildPerfectSoundIcon() {
    final isSpeaking = _isTtsSpeaking;
    final isEnabled = _ttsEnabled;
    return GestureDetector(
      onTap: _toggleTts,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.identity()..scale(isSpeaking ? 1.1 : 1.0),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSpeaking
              ? Colors.red.shade400
              : isEnabled
              ? Colors.orange.shade400
              : Colors.grey.shade400,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSpeaking || isEnabled
              ? Icons.volume_up_rounded
              : Icons.volume_off_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFirstAidCard(String text, int messageIndex) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade500, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "🏥 FIRST AID INSTRUCTIONS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildPerfectSoundIcon(),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Build critical emergency card
  Widget _buildCriticalCard(String text, int messageIndex) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade700, Colors.red.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade300,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "CRITICAL EMERGENCY",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _buildPerfectSoundIcon(),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            if (_dialogueManager.hasIntent) ...[
              Icon(Icons.medical_services, size: 20),
              SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                _dialogueManager.hasIntent
                    ? _dialogueManager.currentIntent!
                    .replaceAll('_', ' ')
                    .toUpperCase()
                    : "🚨 Emergency Assistant",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // NEW: Show severity indicator if detected
          if (_dialogueManager.detectedSeverity != EmergencySeverity.unknown)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(_dialogueManager.detectedSeverity),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _dialogueManager.detectedSeverity,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildPerfectSoundIcon(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _modelLoaded
                ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isUser = msg["isUser"] as bool;
                final type = msg["type"] as String?;
                final image = msg["image"] as File?;

                // Special card for critical messages
                if (type == "critical") {
                  return _buildCriticalCard(msg["text"] as String, i);
                }

                // Special card for first aid steps
                if (type == "steps") {
                  return _buildFirstAidCard(msg["text"] as String, i);
                }

                // Regular message bubble
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.82,
                    ),
                    decoration: BoxDecoration(
                      color: _bubbleColor(type, isUser),
                      borderRadius: BorderRadius.circular(20),
                      border: type == "warning"
                          ? Border.all(color: Colors.red.shade700, width: 2)
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (image != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              image,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          msg["text"] as String,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                            fontSize: 16,
                            height: 1.4,
                            fontWeight: type == "critical" || type == "warning"
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red.shade700),
                  const SizedBox(height: 16),
                  Text(
                    "Loading AI Model...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // NEW: Show processing indicator
          if (_isProcessingText)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Analyzing...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          _buildInputBar(),
          _buildDisclaimer(),
        ],
      ),
    );
  }

  // NEW: Get severity indicator color
  Color _getSeverityColor(String severity) {
    switch (severity) {
      case EmergencySeverity.critical:
        return Colors.red.shade900;
      case EmergencySeverity.urgent:
        return Colors.orange.shade700;
      case EmergencySeverity.nonUrgent:
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: Row(
          children: [
            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(fontSize: 16),
                  enabled: !_isProcessingText && !_isProcessingImage,  // NEW: Disable during processing
                  onSubmitted: (text) {
                    final trimmed = text.trim();
                    if (trimmed.isNotEmpty && !_isProcessingText) {
                      _textController.clear();
                      _sendMessage(trimmed);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: _isProcessingText
                        ? "Processing..."
                        : "Type or send image...",
                    hintStyle: TextStyle(
                      color: _isProcessingText
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Image/Camera button
            GestureDetector(
              onTap: (_isProcessingImage || _isProcessingText) ? null : () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('Take Photo'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickAndClassifyImage(ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('Choose from Gallery'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickAndClassifyImage(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_isProcessingImage || _isProcessingText)
                      ? Colors.grey.shade400
                      : (_imageModelLoaded ? Colors.purple.shade400 : Colors.grey.shade400),
                  shape: BoxShape.circle,
                ),
                child: _isProcessingImage
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.add_a_photo_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Mic toggle button
            GestureDetector(
              onTap: (_isProcessingText || _isProcessingImage) ? null : _toggleRecording,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_isProcessingText || _isProcessingImage)
                      ? Colors.grey.shade400
                      : (_isRecording ? Colors.red.shade400 : Colors.blue.shade400),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            GestureDetector(
              onTap: (_isProcessingText || _isProcessingImage) ? null : () {
                final text = _textController.text.trim();
                if (text.isNotEmpty) {
                  _textController.clear();
                  _sendMessage(text);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_isProcessingText || _isProcessingImage)
                      ? Colors.grey.shade400
                      : Colors.green.shade500,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


// Add this to see detailed confidence breakdown

  // Replace your _buildDisclaimer() method in emergency_page.dart with this:

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          // Show confidence if we have an intent (even if conversation is complete)
          if (_dialogueManager.hasIntent && _dialogueManager.intentConfidence > 0)
            Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                      SizedBox(width: 8),
                      Text(
                        "Intent Confidence: ${(_dialogueManager.intentConfidence * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Show severity confidence if detected
                  if (_dialogueManager.detectedSeverity != EmergencySeverity.unknown &&
                      _dialogueManager.severityConfidence > 0)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        "Severity Confidence: ${(_dialogueManager.severityConfidence * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          const Text(
            "⚠️ Disclaimer: This assistant is for guidance only. "
                "It cannot replace professional medical care. "
                "In any emergency, seek immediate help from qualified medical personnel.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ttsEnabled = false;
    _isTtsSpeaking = false;
    _textController.dispose();
    _audioService.dispose();
    _ttsService.stop();
    _imageClassifier.dispose();
    _ttsAnimationController.dispose();
    super.dispose();
  }
}