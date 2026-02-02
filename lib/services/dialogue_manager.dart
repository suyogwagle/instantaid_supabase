// lib/services/dialogue_manager.dart
// MODIFIED VERSION - Replace your existing file with this

import 'emergency_severity.dart';  // NEW IMPORT
import 'confidence_system.dart';   // NEW IMPORT

class RuleEngine {
  final Map<dynamic, dynamic> rules;
  RuleEngine(this.rules);

  String? evaluate(int questionIndex, String answer) {
    final rawRuleSet = rules[questionIndex];
    if (rawRuleSet == null) return null;
    final ruleSet = Map<String, String>.from(rawRuleSet as Map);
    for (final entry in ruleSet.entries) {
      if (_matchRule(answer, entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  bool _matchRule(String answer, String keyword) {
    final normalized = answer.toLowerCase().trim();
    final k = keyword.toLowerCase().trim();

    if (k == "yes" || k == "हो") {
      return ["yes", "y", "हो", "हुन्छ"].any(normalized.contains);
    }
    if (k == "no" || k == "होइन") {
      return ["no", "n", "होइन", "हुँदैन"].any(normalized.contains);
    }
    if (k == "unknown" || k == "थाहा छैन") {
      return ["unknown", "dont know", "not sure", "thaha", "नथाहा"]
          .any(normalized.contains);
    }
    return normalized.contains(k);
  }
}

class DialogueManager {
  String? _currentIntent;
  int _questionIndex = 0;
  bool _isComplete = false;
  final List<String> _answers = [];
  final List<String> _log = [];
  final DateTime Function() _now;
  late RuleEngine _ruleEngine;

  // NEW: Severity and confidence tracking
  String _detectedSeverity = EmergencySeverity.unknown;
  double _severityConfidence = 0.0;
  double _intentConfidence = 0.0;  // Set from outside when intent is detected

  final Map<String, Map<String, dynamic>> englishGuidelines;
  final Map<String, Map<String, dynamic>> nepaliGuidelines;
  late Map<String, Map<String, dynamic>> activeGuidelines;

  DialogueManager(this.englishGuidelines, this.nepaliGuidelines,
      {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  bool get hasIntent => _currentIntent != null;
  bool isConversationComplete() => _isComplete;
  String? get currentIntent => _currentIntent;

  // NEW: Getters for severity and confidence
  String get detectedSeverity => _detectedSeverity;
  double get severityConfidence => _severityConfidence;
  double get intentConfidence => _intentConfidence;

  List<String> get answers => List.unmodifiable(_answers);
  List<String> get conversationLog => List.unmodifiable(_log);

  void reset() {
    _currentIntent = null;
    _questionIndex = 0;
    _isComplete = false;
    _answers.clear();
    _log.clear();
    _detectedSeverity = EmergencySeverity.unknown;
    _severityConfidence = 0.0;
    _intentConfidence = 0.0;
  }

  // NEW: Setter for intent confidence (call this from your main app)
  void setIntentConfidence(double confidence) {
    _intentConfidence = confidence;
    _recordLog("Intent confidence set: ${(_intentConfidence * 100).toStringAsFixed(1)}%");
  }

  List<String> start(String intent, {String? userText, double intentConfidence = 0.7}) {
    final isNepali = userText != null && _isNepali(userText);
    activeGuidelines = isNepali ? nepaliGuidelines : englishGuidelines;

    // NEW: Set intent confidence
    _intentConfidence = intentConfidence;

    // NEW: Check initial severity from user's description
    if (userText != null) {
      final severityResult = EnhancedCriticalDetector.detectSeverity(userText);
      _detectedSeverity = severityResult["severity"];
      _severityConfidence = severityResult["confidence"];
      _recordLog("Initial severity: $_detectedSeverity (${(_severityConfidence * 100).toStringAsFixed(1)}%)");

      // If CRITICAL detected immediately, skip questions
      if (_detectedSeverity == EmergencySeverity.critical) {
        _isComplete = true;
        final guideline = activeGuidelines[intent];
        final criticalInstructions = guideline?["critical_instructions"] as List<String>? ?? [];

        return [
          isNepali
              ? "🚨 गम्भीर आपतकालीन अवस्था पत्ता लाग्यो!"
              : "🚨 CRITICAL EMERGENCY DETECTED!",
          EnhancedCriticalDetector.getRecommendedAction(_detectedSeverity, isNepali: isNepali),
          criticalInstructions.join('\n')
        ];
      }
    }

    final guideline = activeGuidelines[intent];
    if (guideline == null) {
      return isNepali
          ? [
        "❌ क्षमा गर्नुहोस्, यो आपतकालीन प्रकार अझै समर्थित छैन।",
        "✅ प्रयास गर्नुहोस्: सर्पदंश, जलन, हड्डी भाँचिने, घाँटी अड्किने, मुटु आक्रमण, घाउ, विषाक्तता, उचाइ रोग, सडक दुर्घटना, बिजुलीको झटका, एलर्जी प्रतिक्रिया, सामान्य चिसो"
      ]
          : [
        "❌ Sorry, this emergency type is not supported yet.",
        "✅ Try: snake bite, burn, fracture, choking, cardiac attack, wound, poisoning, altitude sickness, road accident, electric shock, allergic reaction, common cold"
      ];
    }

    _currentIntent = intent;
    _questionIndex = 0;
    _isComplete = false;
    _answers.clear();
    _log.clear();

    _ruleEngine = RuleEngine(guideline["rules"] as Map<dynamic, dynamic>? ?? {});

    final questions = guideline["questions"] as List<String>? ?? [];
    final firstQ = questions.isNotEmpty
        ? questions[0]
        : isNepali
        ? "के व्यक्ति बेहोस छन् वा सास फेर्न सकेका छैनन्?"
        : "Is the person unconscious, not breathing normally, or bleeding heavily?";

    final detectedLabel = isNepali
        ? "✅ पत्ता लाग्यो: ${intent.replaceAll('_', ' ').toUpperCase()}"
        : "✅ DETECTED: ${intent.replaceAll('_', ' ').toUpperCase()}";

    // NEW: Show severity if detected
    List<String> response = [detectedLabel];

    if (_detectedSeverity != EmergencySeverity.unknown) {
      response.add(EnhancedCriticalDetector.getRecommendedAction(_detectedSeverity, isNepali: isNepali));
    }

    final checkLabel = isNepali
        ? "📋 कृपया गम्भीरता जाँच गर्नुहोस्:"
        : "📋 First, a quick criticality check:";

    response.addAll([checkLabel, firstQ]);

    _recordLog("START: $intent (${isNepali ? "NP" : "EN"}) - Severity: $_detectedSeverity");
    return response;
  }

  List<String> next(String userAnswer) {
    final isNepali = _isNepali(userAnswer);

    if (_currentIntent == null) {
      return isNepali
          ? ["कृपया पहिले आपतकालीन अवस्था वर्णन गर्नुहोस्।"]
          : ["Please describe the emergency first."];
    }
    if (_isComplete) {
      return isNepali
          ? ["✅ मार्गदर्शन पूरा भयो। 'नयाँ आपतकालीन' भन्नुहोस् पुन: सुरु गर्न।"]
          : ["✅ Guidance complete. Say 'new emergency' to start fresh."];
    }

    _answers.add(userAnswer);
    _recordLog("Q$_questionIndex: $userAnswer");

    // NEW: Check response quality and ask for clarification if needed
    final quality = ConfidenceSystem.analyzeResponseQuality(userAnswer);
    if (quality == "unclear" || quality == "vague") {
      final clarifications = ConfidenceSystem.getClarifyingQuestions(
        intent: _currentIntent!,
        vagueAnswer: userAnswer,
        isNepali: isNepali,
      );

      if (clarifications.isNotEmpty) {
        _recordLog("Requesting clarification: quality=$quality");
        // Don't increment question index, wait for better answer
        return clarifications;
      }
    }

    // NEW: Re-evaluate severity with each answer
    final severityResult = EnhancedCriticalDetector.detectSeverity(userAnswer);
    final newSeverity = severityResult["severity"];
    final newConfidence = severityResult["confidence"];

    if (_isSeverityWorse(newSeverity, _detectedSeverity)) {
      _detectedSeverity = newSeverity;
      _severityConfidence = newConfidence;
      _recordLog("Severity escalated to: $_detectedSeverity");
    }

    final guideline = activeGuidelines[_currentIntent!]!;
    final questions = guideline["questions"] as List<String>? ?? [];
    final instructions = guideline["instructions"] as List<String>? ?? [];
    final criticalInstructions = guideline["critical_instructions"] as List<String>? ?? [];

    // NEW: Check if severity escalated to CRITICAL
    if (_detectedSeverity == EmergencySeverity.critical) {
      _isComplete = true;
      _recordLog("CRITICAL SEVERITY DETECTED");
      return [
        EnhancedCriticalDetector.getRecommendedAction(_detectedSeverity, isNepali: isNepali),
        criticalInstructions.join('\n')
      ];
    }

    // Original rule engine check
    final outcome = _ruleEngine.evaluate(_questionIndex, userAnswer);
    if (outcome == "critical") {
      _isComplete = true;
      _recordLog("OUTCOME: CRITICAL (rule-based)");
      return [criticalInstructions.join('\n')];
    } else if (outcome == "instructions") {
      _isComplete = true;
      _recordLog("OUTCOME: INSTRUCTIONS (rule-based)");
      return [instructions.join('\n')];
    }

    if (_questionIndex < questions.length - 1) {
      _questionIndex++;
      final nextQ = questions[_questionIndex];
      _recordLog("ASK Q$_questionIndex: $nextQ");
      return [nextQ];
    }

    // End of questions - NEW: perform safety check
    _isComplete = true;

    final overallConf = ConfidenceSystem.calculateOverallConfidence(
      intentConfidence: _intentConfidence,
      severityConfidence: _severityConfidence,
      questionsAnswered: _questionIndex + 1,
      totalQuestions: questions.length,
      userResponseQuality: quality,
    );

    final safetyCheck = ConfidenceSystem.performSafetyCheck(
      overallConfidence: overallConf["confidence"],
      severity: _detectedSeverity,
      intent: _currentIntent!,
    );

    _recordLog("END: Confidence=${(overallConf['confidence'] * 100).toStringAsFixed(1)}%, "
        "Level=${overallConf['level']}, Safe=${safetyCheck['safe_to_proceed']}");

    List<String> finalResponse = [];

    // Add warnings if any
    if (safetyCheck["warnings"].isNotEmpty) {
      for (final warning in safetyCheck["warnings"]) {
        finalResponse.add(warning);
      }
    }

    // Add severity recommendation if urgent
    if (_detectedSeverity == EmergencySeverity.urgent) {
      finalResponse.add(EnhancedCriticalDetector.getRecommendedAction(_detectedSeverity, isNepali: isNepali));
    }

    // Add instructions if safe
    if (safetyCheck["safe_to_proceed"]) {
      finalResponse.add(instructions.join('\n'));
    } else {
      finalResponse.add(isNepali
          ? "❌ पर्याप्त जानकारी छैन। कृपया तुरुन्त चिकित्सक वा 102/103 मा सम्पर्क गर्नुहोस्।"
          : "❌ Insufficient information. Please contact a medical professional or call 102/103 immediately.");
    }

    return finalResponse;
  }

  bool _isSeverityWorse(String newSeverity, String currentSeverity) {
    const severityRank = {
      EmergencySeverity.unknown: 0,
      EmergencySeverity.nonUrgent: 1,
      EmergencySeverity.urgent: 2,
      EmergencySeverity.critical: 3,
    };

    return (severityRank[newSeverity] ?? 0) > (severityRank[currentSeverity] ?? 0);
  }

  bool _isNepali(String text) {
    return RegExp(r"[अ-ह]").hasMatch(text) ||
        text.contains("हो") ||
        text.contains("होइन") ||
        text.contains("थाहा छैन");
  }

  void _recordLog(String entry) {
    _log.add("${_now().toIso8601String().substring(0, 19)} - $entry");
  }
}