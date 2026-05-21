// lib/services/bot_message_type.dart
//
// Classifies bot message text for UI styling. Avoids false "critical"
// cards when Nepali text contains गम्भीरता (severity check) or English
// "criticality" (substring of CRITICAL).

class BotMessageType {
  BotMessageType._();

  static String infer(String msg) {
    final trimmed = msg.trim();

    if (_isTriageQuestion(trimmed) && !_isCriticalEmergencyBanner(trimmed)) {
      return 'question';
    }

    if (_isCriticalEmergencyBanner(trimmed)) {
      return 'critical';
    }

    if (msg.contains('FIRST AID') ||
        msg.contains('IMMEDIATE ACTION') ||
        msg.contains('तुरुन्त गर्नुपर्ने')) {
      return 'steps';
    }

    if (msg.contains('⚠️') || msg.contains('WARNING')) {
      return 'warning';
    }

    if (_isIntentDetectionIntro(trimmed)) {
      return 'intro';
    }

    return 'intro';
  }

  /// Clinical yes/no questions from guidelines — not emergency banners.
  static bool _isTriageQuestion(String msg) {
    if (msg.contains('?')) return true;
    if (RegExp(r'^के\s').hasMatch(msg)) return true;
    if (RegExp(r'^(Is|Are|Does|Do|Was|Were|Can)\s', caseSensitive: false)
        .hasMatch(msg)) {
      return true;
    }
    return false;
  }

  static bool _isIntentDetectionIntro(String msg) {
    if (msg.contains('पत्ता लाग्यो:')) return true;
    if (RegExp(r"i'm pretty sure it's", caseSensitive: false).hasMatch(msg)) {
      return true;
    }
    if (msg.contains('छिटो प्रश्न') || msg.contains('quick safety questions')) {
      return true;
    }
    return false;
  }

  /// Full-width critical emergency card — not severity-check or triage copy.
  static bool _isCriticalEmergencyBanner(String msg) {
    if (msg.contains('CRITICAL EMERGENCY!') ||
        msg.contains('CRITICAL EMERGENCY DETECTED') ||
        msg.contains('गम्भीर आपतकालीन अवस्था')) {
      return true;
    }

    // Post-triage critical protocol (🚨 गम्भीर जलन: / 🚨 CRITICAL BURN:)
    if (RegExp(r'^🚨\s*गम्भीर\s+').hasMatch(msg)) return true;
    if (RegExp(r'^🚨\s*CRITICAL\s', caseSensitive: false).hasMatch(msg)) {
      return true;
    }

    // DialogueManager critical skip path
    if (msg.contains('CRITICAL EMERGENCY DETECTED')) return true;

    return false;
  }
}
