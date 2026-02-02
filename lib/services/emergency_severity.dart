
import 'dart:math' as math;

class EmergencySeverity {
  static const String critical = "CRITICAL";
  static const String urgent = "URGENT";
  static const String nonUrgent = "NON_URGENT";
  static const String unknown = "UNKNOWN";
}

class EnhancedCriticalDetector {
  // Multi-level severity patterns
  static final Map<String, List<RegExp>> severityPatterns = {
    EmergencySeverity.critical: [
      // Life-threatening - English
      RegExp(r"\b(unconscious|not conscious|passed out|fainted)\b", caseSensitive: false),
      RegExp(r"\b(not breathing|stopped breathing|can'?t breathe)\b", caseSensitive: false),
      RegExp(r"\b(no pulse|heart stopped|cardiac arrest)\b", caseSensitive: false),
      RegExp(r"\b(not responsive|unresponsive)\b", caseSensitive: false),
      RegExp(r"\b(seizure|convuls(ing|ion)|fitting)\b", caseSensitive: false),
      RegExp(r"\b(severe bleeding|heavy bleeding|blood gushing|spurting)\b", caseSensitive: false),
      RegExp(r"\b(choking|can'?t swallow|airway blocked)\b", caseSensitive: false),
      RegExp(r"\b(chest pain|heart attack|crushing pain)\b", caseSensitive: false),

      // Nepali critical
      RegExp(r"बेहोस"),
      RegExp(r"सास\s*(फेर्न\s*)?(रोकिएको|बन्द|छैन)"),
      RegExp(r"मुटु\s*रोकिएको"),
      RegExp(r"धेरै\s*रगत"),
      RegExp(r"दौरा"),
    ],

    EmergencySeverity.urgent: [
      // Serious but stable - English
      RegExp(r"\b(deep (cut|wound|laceration)|gash)\b", caseSensitive: false),
      RegExp(r"\b(broken bone|fractured|dislocated)\b", caseSensitive: false),
      RegExp(r"\b(severe burn|third degree)\b", caseSensitive: false),
      RegExp(r"\b(snake bite|venomous)\b", caseSensitive: false),
      RegExp(r"\b(high fever|temperature above 103)\b", caseSensitive: false),
      RegExp(r"\b(difficulty breathing|shortness of breath)\b", caseSensitive: false),
      RegExp(r"\b(severe pain|excruciating|unbearable)\b", caseSensitive: false),

      // Nepali urgent
      RegExp(r"हड्डी\s*भाँचि"),
      RegExp(r"सर्प(को)?\s*टोक"),
      RegExp(r"गहिरो\s*घाउ"),
      RegExp(r"उच्च\s*ज्वरो"),
    ],

    EmergencySeverity.nonUrgent: [
      // Minor issues - English
      RegExp(r"\b(minor (cut|scratch|bruise)|small wound)\b", caseSensitive: false),
      RegExp(r"\b(superficial burn|sunburn)\b", caseSensitive: false),
      RegExp(r"\b(sprain|twisted ankle)\b", caseSensitive: false),
      RegExp(r"\b(common cold|flu|cough|sore throat)\b", caseSensitive: false),

      // Nepali non-urgent
      RegExp(r"सामान्य\s*चोट"),
      RegExp(r"हल्का\s*(जलन|घाउ)"),
      RegExp(r"रुघा\s*खोकी"),
    ],
  };

  /// Detect severity with confidence
  static Map<String, dynamic> detectSeverity(String userInput) {
    final input = userInput.toLowerCase();

    // Check critical first (highest priority)
    int criticalMatches = 0;
    for (final pattern in severityPatterns[EmergencySeverity.critical]!) {
      if (pattern.hasMatch(input)) {
        criticalMatches++;
      }
    }
    if (criticalMatches > 0) {
      return {
        "severity": EmergencySeverity.critical,
        "confidence": math.min(1.0, criticalMatches / 3.0),
        "matches": criticalMatches,
      };
    }

    // Check urgent
    int urgentMatches = 0;
    for (final pattern in severityPatterns[EmergencySeverity.urgent]!) {
      if (pattern.hasMatch(input)) {
        urgentMatches++;
      }
    }
    if (urgentMatches > 0) {
      return {
        "severity": EmergencySeverity.urgent,
        "confidence": math.min(1.0, urgentMatches / 2.0),
        "matches": urgentMatches,
      };
    }

    // Check non-urgent
    int nonUrgentMatches = 0;
    for (final pattern in severityPatterns[EmergencySeverity.nonUrgent]!) {
      if (pattern.hasMatch(input)) {
        nonUrgentMatches++;
      }
    }
    if (nonUrgentMatches > 0) {
      return {
        "severity": EmergencySeverity.nonUrgent,
        "confidence": math.min(1.0, nonUrgentMatches / 2.0),
        "matches": nonUrgentMatches,
      };
    }

    return {
      "severity": EmergencySeverity.unknown,
      "confidence": 0.0,
      "matches": 0,
    };
  }

  /// Get action recommendation
  static String getRecommendedAction(String severity, {bool isNepali = false}) {
    switch (severity) {
      case EmergencySeverity.critical:
        return isNepali
            ? "🚨 तुरुन्त 102/103 मा फोन गर्नुहोस्! यो जीवन-मरणको अवस्था हो।"
            : "🚨 CALL 102/103 IMMEDIATELY! This is life-threatening.";

      case EmergencySeverity.urgent:
        return isNepali
            ? "⚠️ जति सक्दो छिटो अस्पताल जानुहोस्।"
            : "⚠️ Seek medical care as soon as possible.";

      case EmergencySeverity.nonUrgent:
        return isNepali
            ? "ℹ️ घरमै उपचार गर्न सकिन्छ। लक्षण बढेमा डाक्टर देखाउनुहोस्।"
            : "ℹ️ Home treatment may be sufficient. See a doctor if symptoms worsen.";

      default:
        return isNepali
            ? "❓ कृपया थप विवरण दिनुहोस्।"
            : "❓ Please provide more details.";
    }
  }

  /// Check if immediate emergency call needed
  static bool requiresImmediateEmergencyCall(String userInput) {
    final severity = detectSeverity(userInput);
    return severity["severity"] == EmergencySeverity.critical;
  }
}