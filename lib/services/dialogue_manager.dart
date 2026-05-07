// lib/services/dialogue_manager.dart

import 'emergency_severity.dart';
import 'confidence_system.dart';
import 'context_gatherer.dart'; // NEW

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

// ── Conversation phases ────────────────────────────────────────────────────

enum DialoguePhase {
  /// No intent detected yet — we have not even started.
  idle,

  /// Confidence is low; we are asking context questions to enrich the input
  /// before locking in an intent.
  gatheringContext,

  /// Intent is confirmed; we are running the clinical rule-based Q&A.
  clinicalQA,

  /// Guidance has been delivered; conversation is done.
  complete,
}

// ── Main class ─────────────────────────────────────────────────────────────

class DialogueManager {
  // ── Phase tracking ─────────────────────────────────────────────────────
  DialoguePhase _phase = DialoguePhase.idle;
  DialoguePhase get phase => _phase;

  // ── Intent & confidence ────────────────────────────────────────────────
  String? _currentIntent;
  double _intentConfidence = 0.0;

  // ── Severity ───────────────────────────────────────────────────────────
  String _detectedSeverity = EmergencySeverity.unknown;
  double _severityConfidence = 0.0;

  // ── Context-gathering state (Phase: gatheringContext) ──────────────────
  /// The raw text the user first typed.
  String _originalUserText = "";

  /// The candidate intent we got from the first (low-confidence) pass.
  String _candidateIntent = "";

  /// Context questions to ask during the gathering phase.
  List<ContextQuestion> _contextQuestions = [];

  /// Index into [_contextQuestions] — which question are we waiting for next.
  int _contextQuestionIndex = 0;

  /// Keys accumulated so far (parallel to [_contextValues]).
  final List<String> _contextKeys = [];

  /// Values (answers) accumulated so far.
  final List<String> _contextValues = [];

  // ── Clinical Q&A state (Phase: clinicalQA) ────────────────────────────
  int _questionIndex = 0;
  final List<String> _answers = [];
  late RuleEngine _ruleEngine;

  // ── Misc ───────────────────────────────────────────────────────────────
  final List<String> _log = [];
  final DateTime Function() _now;

  final Map<String, Map<String, dynamic>> englishGuidelines;
  final Map<String, Map<String, dynamic>> nepaliGuidelines;
  late Map<String, Map<String, dynamic>> activeGuidelines;

  DialogueManager(
    this.englishGuidelines,
    this.nepaliGuidelines, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  // ── Getters ───────────────────────────────────────────────────────────
  bool get hasIntent => _currentIntent != null;
  bool isConversationComplete() => _phase == DialoguePhase.complete;
  String? get currentIntent => _currentIntent;
  String get detectedSeverity => _detectedSeverity;
  double get severityConfidence => _severityConfidence;
  double get intentConfidence => _intentConfidence;
  List<String> get conversationLog => List.unmodifiable(_log);

  /// True when we are mid-context-gathering (caller should NOT yet run the
  /// clinical dialogue; it should call [supplyContextAnswer] instead).
  bool get isGatheringContext => _phase == DialoguePhase.gatheringContext;

  // ── Exposed for external callers (image classifier path) ──────────────
  void setIntentConfidence(double confidence) {
    _intentConfidence = confidence;
    _recordLog(
        "Intent confidence set: ${(_intentConfidence * 100).toStringAsFixed(1)}%");
  }

  // ── Reset ─────────────────────────────────────────────────────────────
  void reset() {
    _phase = DialoguePhase.idle;
    _currentIntent = null;
    _intentConfidence = 0.0;
    _detectedSeverity = EmergencySeverity.unknown;
    _severityConfidence = 0.0;
    _originalUserText = "";
    _candidateIntent = "";
    _contextQuestions = [];
    _contextQuestionIndex = 0;
    _contextKeys.clear();
    _contextValues.clear();
    _questionIndex = 0;
    _answers.clear();
    _log.clear();
  }

  // ════════════════════════════════════════════════════════════════════════
  // Phase 0 → 1/2  :  beginContextGathering  (called from emergency_page)
  // ════════════════════════════════════════════════════════════════════════

  /// Call this when the classifier returned a low-confidence result.
  /// Stores the candidate intent + original text, and returns the FIRST
  /// context question to show the user.
  ///
  /// Returns an empty list if no context questions are available for this
  /// intent (caller should fall through to [start] directly in that case).
  List<String> beginContextGathering({
    required String originalText,
    required String candidateIntent,
    String? alternativeIntent,
    required double initialConfidence,
    required bool isNepali,
  }) {
    _originalUserText = originalText;
    _candidateIntent = candidateIntent;
    _intentConfidence = initialConfidence;
    activeGuidelines = isNepali ? nepaliGuidelines : englishGuidelines;

    final questions = ContextGatherer.getQuestionsForPair(
      primaryIntent: candidateIntent,
      alternativeIntent: alternativeIntent,
    );
    if (questions.isEmpty) {
      // No questions available → skip straight to clinical Q&A.
      _recordLog("No context questions for '$candidateIntent', skipping phase.");
      return [];
    }

    _contextQuestions = questions;
    _contextQuestionIndex = 0;
    _contextKeys.clear();
    _contextValues.clear();
    _phase = DialoguePhase.gatheringContext;

    final q = questions[0];
    final questionText = isNepali ? q.questionNp : q.questionEn;

    final preamble = isNepali
        ? "🔍 मलाई अझ राम्रोसँग बुझ्न सहायता गर्नुहोस्:"
        : "🔍 Help me understand better:";

    _recordLog(
        "CONTEXT_PHASE_START: candidate=$candidateIntent, conf=${(initialConfidence * 100).toStringAsFixed(1)}%");
    return [preamble, questionText];
  }

  // ════════════════════════════════════════════════════════════════════════
  // Phase 1  :  supplyContextAnswer
  // ════════════════════════════════════════════════════════════════════════

  /// Feed one context answer.  Returns either the NEXT context question, OR
  /// a [ContextGatherResult] signalling that gathering is done and the caller
  /// must re-classify with [HybridIntentClassifier.classifyWithContext].
  ContextGatherResult supplyContextAnswer(
      String answer, bool isNepali) {
    if (_phase != DialoguePhase.gatheringContext) {
      return ContextGatherResult.notInGatheringPhase();
    }

    final currentQ = _contextQuestions[_contextQuestionIndex];
    _contextKeys.add(
        isNepali ? currentQ.contextKeyNp : currentQ.contextKeyEn);
    _contextValues.add(answer.trim());

    _recordLog("CONTEXT_Q$_contextQuestionIndex: ${_contextKeys.last} = ${_contextValues.last}");
    _contextQuestionIndex++;

    if (_contextQuestionIndex < _contextQuestions.length) {
      // More questions to ask.
      final nextQ = _contextQuestions[_contextQuestionIndex];
      final questionText = isNepali ? nextQ.questionNp : nextQ.questionEn;
      return ContextGatherResult.askNextQuestion(questionText);
    }

    // All context collected → tell the caller to re-classify.
    return ContextGatherResult.readyForReclassification(
      originalText: _originalUserText,
      candidateIntent: _candidateIntent,
      contextKeys: List.unmodifiable(_contextKeys),
      contextValues: List.unmodifiable(_contextValues),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // Phase 1→2  :  confirmIntentAfterContext  (called after re-classification)
  // ════════════════════════════════════════════════════════════════════════

  /// Call this once the re-classification is done.
  /// Transitions into clinicalQA and returns the same output as [start].
  List<String> confirmIntentAfterContext({
    required String confirmedIntent,
    required double confirmedConfidence,
    required bool isNepali,
  }) {
    _intentConfidence = confirmedConfidence;

    _recordLog(
        "CONTEXT_PHASE_END: confirmed=$confirmedIntent, conf=${(confirmedConfidence * 100).toStringAsFixed(1)}%");

    // Delegate to the normal start flow.
    // We pass the original text so severity detection still works.
    return start(
      confirmedIntent,
      userText: _originalUserText,
      intentConfidence: confirmedConfidence,
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // Phase 2  :  start  (existing behaviour, now also called internally)
  // ════════════════════════════════════════════════════════════════════════

  List<String> start(
    String intent, {
    String? userText,
    double intentConfidence = 0.7,
  }) {
    final isNepali = userText != null && _isNepali(userText);
    activeGuidelines = isNepali ? nepaliGuidelines : englishGuidelines;

    _intentConfidence = intentConfidence;

    // Severity check on initial description.
    if (userText != null) {
      final severityResult = EnhancedCriticalDetector.detectSeverity(userText);
      _detectedSeverity = severityResult["severity"];
      _severityConfidence = severityResult["confidence"];
      _recordLog(
          "Initial severity: $_detectedSeverity (${(_severityConfidence * 100).toStringAsFixed(1)}%)");

      // If CRITICAL → skip questions, go straight to critical instructions.
      if (_detectedSeverity == EmergencySeverity.critical) {
        _phase = DialoguePhase.complete;
        final guideline = activeGuidelines[intent];
        final criticalInstructions =
            guideline?["critical_instructions"] as List<String>? ?? [];
        return [
          isNepali
              ? "🚨 गम्भीर आपतकालीन अवस्था पत्ता लाग्यो!"
              : "🚨 CRITICAL EMERGENCY DETECTED!",
          EnhancedCriticalDetector.getRecommendedAction(_detectedSeverity,
              isNepali: isNepali),
          criticalInstructions.join('\n'),
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
    _phase = DialoguePhase.clinicalQA;
    _answers.clear();

    _ruleEngine =
        RuleEngine(guideline["rules"] as Map<dynamic, dynamic>? ?? {});

    final questions = guideline["questions"] as List<String>? ?? [];
    final firstQ = questions.isNotEmpty
        ? questions[0]
        : isNepali
            ? "के व्यक्ति बेहोस छन् वा सास फेर्न सकेका छैनन्?"
            : "Is the person unconscious, not breathing normally, or bleeding heavily?";

    final detectedLabel = isNepali
        ? "✅ पत्ता लाग्यो: ${intent.replaceAll('_', ' ').toUpperCase()}"
        : "✅ DETECTED: ${intent.replaceAll('_', ' ').toUpperCase()}";

    List<String> response = [detectedLabel];

    if (_detectedSeverity != EmergencySeverity.unknown) {
      response.add(EnhancedCriticalDetector.getRecommendedAction(
          _detectedSeverity,
          isNepali: isNepali));
    }

    final checkLabel = isNepali
        ? "📋 कृपया गम्भीरता जाँच गर्नुहोस्:"
        : "📋 First, a quick criticality check:";

    response.addAll([checkLabel, firstQ]);

    _recordLog(
        "START: $intent (${isNepali ? "NP" : "EN"}) - Severity: $_detectedSeverity");
    return response;
  }

  // ════════════════════════════════════════════════════════════════════════
  // Phase 2  :  next  (unchanged clinical Q&A logic)
  // ════════════════════════════════════════════════════════════════════════

  List<String> next(String userAnswer) {
    final isNepali = _isNepali(userAnswer);

    if (_currentIntent == null) {
      return isNepali
          ? ["कृपया पहिले आपतकालीन अवस्था वर्णन गर्नुहोस्।"]
          : ["Please describe the emergency first."];
    }
    if (_phase == DialoguePhase.complete) {
      return isNepali
          ? ["✅ मार्गदर्शन पूरा भयो। 'नयाँ आपतकालीन' भन्नुहोस् पुन: सुरु गर्न।"]
          : ["✅ Guidance complete. Say 'new emergency' to start fresh."];
    }

    _answers.add(userAnswer);
    _recordLog("Q$_questionIndex: $userAnswer");

    // Response quality check.
    final quality = ConfidenceSystem.analyzeResponseQuality(userAnswer);
    if (quality == "unclear" || quality == "vague") {
      final clarifications = ConfidenceSystem.getClarifyingQuestions(
        intent: _currentIntent!,
        vagueAnswer: userAnswer,
        isNepali: isNepali,
      );
      if (clarifications.isNotEmpty) {
        _recordLog("Requesting clarification: quality=$quality");
        return clarifications;
      }
    }

    // Re-evaluate severity.
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
    final criticalInstructions =
        guideline["critical_instructions"] as List<String>? ?? [];

    if (_detectedSeverity == EmergencySeverity.critical) {
      _phase = DialoguePhase.complete;
      _recordLog("CRITICAL SEVERITY DETECTED");
      return [
        EnhancedCriticalDetector.getRecommendedAction(_detectedSeverity,
            isNepali: isNepali),
        criticalInstructions.join('\n'),
      ];
    }

    final outcome = _ruleEngine.evaluate(_questionIndex, userAnswer);
    if (outcome == "critical") {
      _phase = DialoguePhase.complete;
      _recordLog("OUTCOME: CRITICAL (rule-based)");
      return [criticalInstructions.join('\n')];
    } else if (outcome == "instructions") {
      _phase = DialoguePhase.complete;
      _recordLog("OUTCOME: INSTRUCTIONS (rule-based)");
      return [instructions.join('\n')];
    }

    if (_questionIndex < questions.length - 1) {
      _questionIndex++;
      final nextQ = questions[_questionIndex];
      _recordLog("ASK Q$_questionIndex: $nextQ");
      return [nextQ];
    }

    // End of questions.
    _phase = DialoguePhase.complete;

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

    _recordLog(
        "END: Confidence=${(overallConf['confidence'] * 100).toStringAsFixed(1)}%, "
        "Level=${overallConf['level']}, Safe=${safetyCheck['safe_to_proceed']}");

    List<String> finalResponse = [];

    if (safetyCheck["warnings"].isNotEmpty) {
      for (final warning in safetyCheck["warnings"]) {
        finalResponse.add(warning);
      }
    }
    if (_detectedSeverity == EmergencySeverity.urgent) {
      finalResponse.add(EnhancedCriticalDetector.getRecommendedAction(
          _detectedSeverity,
          isNepali: isNepali));
    }
    if (safetyCheck["safe_to_proceed"]) {
      finalResponse.add(instructions.join('\n'));
    } else {
      finalResponse.add(isNepali
          ? "❌ पर्याप्त जानकारी छैन। कृपया तुरुन्त चिकित्सक वा 102/103 मा सम्पर्क गर्नुहोस्।"
          : "❌ Insufficient information. Please contact a medical professional or call 102/103 immediately.");
    }

    return finalResponse;
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  bool _isSeverityWorse(String newSeverity, String currentSeverity) {
    const severityRank = {
      EmergencySeverity.unknown: 0,
      EmergencySeverity.nonUrgent: 1,
      EmergencySeverity.urgent: 2,
      EmergencySeverity.critical: 3,
    };
    return (severityRank[newSeverity] ?? 0) >
        (severityRank[currentSeverity] ?? 0);
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

// ── ContextGatherResult 

/// Returned by [DialogueManager.supplyContextAnswer].
class ContextGatherResult {
  final bool isDone;
  final String? nextQuestion;

  // When isDone == true:
  final String? originalText;
  final String? candidateIntent;
  final List<String>? contextKeys;
  final List<String>? contextValues;

  ContextGatherResult._({
    required this.isDone,
    this.nextQuestion,
    this.originalText,
    this.candidateIntent,
    this.contextKeys,
    this.contextValues,
  });

  factory ContextGatherResult.askNextQuestion(String question) =>
      ContextGatherResult._(isDone: false, nextQuestion: question);

  factory ContextGatherResult.readyForReclassification({
    required String originalText,
    required String candidateIntent,
    required List<String> contextKeys,
    required List<String> contextValues,
  }) =>
      ContextGatherResult._(
        isDone: true,
        originalText: originalText,
        candidateIntent: candidateIntent,
        contextKeys: contextKeys,
        contextValues: contextValues,
      );

  factory ContextGatherResult.notInGatheringPhase() =>
      ContextGatherResult._(isDone: false);
}