
class ConfidenceSystem {

  /// Calculate overall confidence
  static Map<String, dynamic> calculateOverallConfidence({
    required double intentConfidence,
    required double severityConfidence,
    required int questionsAnswered,
    required int totalQuestions,
    required String userResponseQuality,
  }) {

    // Weighted calculation
    double intentWeight = 0.35;
    double severityWeight = 0.30;
    double completionWeight = 0.20;
    double qualityWeight = 0.15;

    double completionScore = totalQuestions > 0
        ? questionsAnswered / totalQuestions
        : 0.0;

    double qualityScore = _getQualityScore(userResponseQuality);

    double overallConfidence =
        (intentConfidence * intentWeight) +
            (severityConfidence * severityWeight) +
            (completionScore * completionWeight) +
            (qualityScore * qualityWeight);

    return {
      "confidence": overallConfidence,
      "level": _getConfidenceLevel(overallConfidence),
      "should_proceed": overallConfidence >= 0.6,
    };
  }

  static double _getQualityScore(String quality) {
    switch (quality) {
      case "detailed": return 1.0;
      case "adequate": return 0.7;
      case "vague": return 0.4;
      case "unclear": return 0.2;
      default: return 0.5;
    }
  }

  static String _getConfidenceLevel(double confidence) {
    if (confidence >= 0.85) return "VERY_HIGH";
    if (confidence >= 0.70) return "HIGH";
    if (confidence >= 0.55) return "MODERATE";
    if (confidence >= 0.40) return "LOW";
    return "VERY_LOW";
  }

  // Analyze response quality
  static String analyzeResponseQuality(String response) {
    final wordCount = response.split(RegExp(r'\s+')).length;

    // Very short yes/no
    if (wordCount <= 2) {
      if (response.toLowerCase().contains(RegExp(r"\b(yes|no|हो|होइन)\b"))) {
        return "adequate";
      }
      return "unclear";
    }

    if (wordCount <= 5) {
      return "vague";
    }

    // Check for descriptive content
    final hasDetails = RegExp(
        r"\b(very|really|quite|severe|mild|about|approximately|धेरै|अलि)\b",
        caseSensitive: false
    ).hasMatch(response);

    if (wordCount >= 6 && hasDetails) {
      return "detailed";
    }

    return "adequate";
  }

  // Get clarifying questions
  static List<String> getClarifyingQuestions({
    required String intent,
    required String vagueAnswer,
    required bool isNepali,
  }) {

    List<String> clarifications = [];

    // If just yes/no (which is fine)
    if (vagueAnswer.toLowerCase().trim() == "yes" ||
        vagueAnswer.toLowerCase().trim() == "no" ||
        vagueAnswer.trim() == "हो" ||
        vagueAnswer.trim() == "होइन") {
      return [];
    }

    final quality = analyzeResponseQuality(vagueAnswer);

    if (quality == "unclear") {
      clarifications.add(isNepali
          ? "मलाई राम्रोसँग बुझिएन। के तपाईं फेरि व्याख्या गर्न सक्नुहुन्छ?"
          : "I didn't quite understand. Could you explain again?");
    }

    if (quality == "vague") {
      clarifications.add(isNepali
          ? "के तपाईं थोरै थप विवरण दिन सक्नुहुन्छ?"
          : "Could you provide a bit more detail?");

      clarifications.addAll(_getContextPrompts(intent, isNepali));
    }

    return clarifications;
  }

  static List<String> _getContextPrompts(String intent, bool isNepali) {
    if (isNepali) {
      switch (intent) {
        case "wound":
          return ["जस्तै: घाउ कति ठूलो छ? रगत बगिरहेको छ?"];
        case "burn":
          return ["जस्तै: जलेको भाग कति ठूलो छ? फोका छन्?"];
        case "snake_bite":
          return ["जस्तै: कहाँ टोकेको? सुन्निएको छ?"];
        default:
          return ["जस्तै: के भयो? कति गम्भीर छ?"];
      }
    } else {
      switch (intent) {
        case "wound":
          return ["For example: How large? Is it bleeding heavily?"];
        case "burn":
          return ["For example: How large is the burn? Any blisters?"];
        case "snake_bite":
          return ["For example: Where was the bite? Is there swelling?"];
        default:
          return ["For example: What happened? How serious is it?"];
      }
    }
  }

  /// Safety check before providing instructions
  static Map<String, dynamic> performSafetyCheck({
    required double overallConfidence,
    required String severity,
    required String intent,
  }) {

    bool isSafe = true;
    List<String> warnings = [];

    if (severity == "CRITICAL") {
      warnings.add("🚨 CRITICAL - Call emergency services immediately");
    }

    if (overallConfidence < 0.5 && severity == "URGENT") {
      warnings.add("⚠️ Uncertain assessment - Strongly recommend calling emergency");
    }

    if (overallConfidence < 0.3) {
      warnings.add("❌ Insufficient information");
      isSafe = false;
    }

    final criticalIntents = [
      "cardiac_attack",
      "electric_shock",
      "poisoning",
      "choking"
    ];

    if (criticalIntents.contains(intent)) {
      warnings.add("⚠️ Requires professional medical care");
    }

    return {
      "safe_to_proceed": isSafe,
      "warnings": warnings,
      "confidence_level": _getConfidenceLevel(overallConfidence),
    };
  }
}