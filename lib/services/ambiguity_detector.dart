// lib/services/ambiguity_detector.dart
//
// KEY FIX: Confusion pair check now scans ALL 12 classes for known
// confusable partners, not just top-2.  So cardiac_attack at rank #4
// with 8% confidence will still trigger the cardiac/altitude confusion
// check — because that's exactly the case the old logic was missing.

import 'package:flutter/foundation.dart';
import 'injury_classifier.dart';

class AmbiguityDetector {

  // ── Thresholds ──────────────────────────────────────────────────────────

  static const double gapThreshold = 0.15;

  /// Absolute confidence floor regardless of gap.
  static const double absoluteFloor = 0.70;

  // ── Confusion map ───────────────────────────────────────────────────────
  // Maps each class to the set of classes that are medically confusable
  // with it.  Checked against ALL 12 class scores, not just top-2.

  static const Map<String, Set<String>> confusableWith = {
    "cardiac_attack"    : {"altitude_sickness", "allergic_reaction", "common_cold"},
    "altitude_sickness" : {"cardiac_attack", "common_cold", "allergic_reaction"},
    "allergic_reaction" : {"common_cold", "choking", "poisoning", "cardiac_attack"},
    "common_cold"       : {"allergic_reaction", "altitude_sickness"},
    "wound"             : {"road_accident", "fracture"},
    "road_accident"     : {"wound", "fracture"},
    "fracture"          : {"wound", "road_accident"},
    "burn"              : {"electric_shock"},
    "electric_shock"    : {"burn"},
    "poisoning"         : {"allergic_reaction", "common_cold"},
    "choking"           : {"allergic_reaction"},
    "snake_bite"        : {"wound"},
  };

  // ── Signature keywords ──────────────────────────────────────────────────
  // Classes that have strong real-world context markers.
  // If the predicted class has a signature but NONE of its keywords appear
  // in the input, the prediction is suspicious.

  static final Map<String, List<RegExp>> _signatureKeywords = {
    "altitude_sickness": [
      RegExp(r"\b(altitude|mountain|trekk|hiking|summit|high\s*elevation|everest|hill|climb)\b",
          caseSensitive: false),
      RegExp(r"उचाइ|पहाड|ट्रेकिङ|हिमाल"),
    ],
    "snake_bite": [
      RegExp(r"\b(snake|serpent|viper|cobra|fang|bite|bitten)\b",
          caseSensitive: false),
      RegExp(r"सर्प|टोक"),
    ],
    "electric_shock": [
      RegExp(r"\b(electric|shock|electro|wire|current|voltage|socket|plug)\b",
          caseSensitive: false),
      RegExp(r"बिजुली|झटका|करेन्ट"),
    ],
    "road_accident": [
      RegExp(r"\b(accident|crash|collision|car|bike|vehicle|road|hit|ran\s*over)\b",
          caseSensitive: false),
      RegExp(r"दुर्घटना|सडक|गाडी"),
    ],
    "burn": [
      RegExp(r"\b(burn|fire|flame|hot|scald|blister|charred|boiling)\b",
          caseSensitive: false),
      RegExp(r"जलन|आगो|तातो"),
    ],
    "poisoning": [
      RegExp(r"\b(poison|toxic|swallow|ingest|chemical|pill|drug|overdose|ate)\b",
          caseSensitive: false),
      RegExp(r"विष|निल|खा"),
    ],
    "choking": [
      RegExp(r"\b(chok|swallow|stuck|throat|airway|can'?t\s*speak|gasp)\b",
          caseSensitive: false),
      RegExp(r"घाँटी|अड्क|निल"),
    ],
    "fracture": [
      RegExp(r"\b(fracture|broken|bone|crack|snap|fall|deform|twisted)\b",
          caseSensitive: false),
      RegExp(r"हड्डी|भाँचि|खुट्टा"),
    ],
  };

  // ── Public API ──────────────────────────────────────────────────────────

  /// Pass in the [ClassificationResult] (from InjuryClassifier.classifyFull)
  /// and the raw user text.  Returns a full ambiguity report.
  static AmbiguityReport evaluate({
    required ClassificationResult result,
    required String userText,
  }) {
    final top1Label = result.top1Label;
    final top1Conf  = result.top1Confidence;
    final top2Label = result.top2Label;
    final top2Conf  = result.top2Confidence;
    final gap       = result.gap;

    final reasons = <AmbiguityReason>[];

    // ── Signal 1: Absolute confidence floor ──────────────────────────────
    if (top1Conf < absoluteFloor) {
      reasons.add(AmbiguityReason.lowAbsoluteConfidence);
    }

    // ── Signal 2: Small top-1 vs top-2 gap ───────────────────────────────
    if (gap < gapThreshold) {
      reasons.add(AmbiguityReason.smallConfidenceGap);
    }

    // ── Signal 3: Known confusable class present in top-N ─────────────────
    // For "ambiguous-by-default" flows, we do NOT apply a confidence threshold.
    // We simply pick the highest-ranked confusable partner if one exists.
    final confusablePartners = confusableWith[top1Label] ?? {};
    String? triggeredConfusable;
    double triggeredConfusableConf = 0.0;

    for (final score in result.allScores) {
      final label = score["label"] as String;
      final conf  = score["confidence"] as double;
      if (label == top1Label) continue;
      if (confusablePartners.contains(label)) {
        // Take the highest-confidence confusable partner.
        if (conf > triggeredConfusableConf) {
          triggeredConfusable     = label;
          triggeredConfusableConf = conf;
        }
      }
    }

    if (triggeredConfusable != null) {
      reasons.add(AmbiguityReason.knownConfusionPair);
      debugPrint("⚠️ Confusion signal: $top1Label (${(top1Conf * 100).toStringAsFixed(1)}%) "
          "↔ $triggeredConfusable (${(triggeredConfusableConf * 100).toStringAsFixed(1)}%)");
    }

    // ── Signal 4: Signature keyword missing ───────────────────────────────
    if (_signatureKeywordMissing(top1Label, userText)) {
      reasons.add(AmbiguityReason.signatureKeywordMissing);
    }

    return AmbiguityReport(
      top1Label             : top1Label,
      top1Confidence        : top1Conf,
      top2Label             : top2Label,
      top2Confidence        : top2Conf,
      gap                   : gap,
      isAmbiguous           : reasons.isNotEmpty,
      reasons               : reasons,
      alternativeLabel      : triggeredConfusable ?? top2Label,
      allScores             : result.allScores,
    );
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  /// True when [label] has signature patterns defined and at least one matches [text].
  static bool hasSignatureKeywords(String label, String text) {
    final patterns = _signatureKeywords[label];
    if (patterns == null) return false;
    return patterns.any((p) => p.hasMatch(text));
  }

  static bool _signatureKeywordMissing(String label, String text) {
    final patterns = _signatureKeywords[label];
    if (patterns == null) return false;
    return !hasSignatureKeywords(label, text);
  }
}

// ── Enums and value objects ────────────────────────────────────────────────

enum AmbiguityReason {
  lowAbsoluteConfidence,    // top1 < 70%
  smallConfidenceGap,       // top1 - top2 < 15pp
  knownConfusionPair,       // a confusable class has >= 5% confidence
  signatureKeywordMissing,  // predicted class missing its key context words
}

class AmbiguityReport {
  final String  top1Label;
  final double  top1Confidence;
  final String  top2Label;
  final double  top2Confidence;
  final double  gap;
  final bool    isAmbiguous;
  final List<AmbiguityReason> reasons;
  /// The most relevant alternative class (best confusable partner, or top-2).
  final String  alternativeLabel;
  final List<Map<String, dynamic>> allScores;

  const AmbiguityReport({
    required this.top1Label,
    required this.top1Confidence,
    required this.top2Label,
    required this.top2Confidence,
    required this.gap,
    required this.isAmbiguous,
    required this.reasons,
    required this.alternativeLabel,
    required this.allScores,
  });

  String get debugSummary {
    final buf = StringBuffer();
    buf.writeln("Top-1 : $top1Label  ${(top1Confidence * 100).toStringAsFixed(1)}%");
    buf.writeln("Top-2 : $top2Label  ${(top2Confidence * 100).toStringAsFixed(1)}%");
    buf.writeln("Gap   : ${(gap * 100).toStringAsFixed(1)} pp");
    buf.writeln("Ambiguous : $isAmbiguous");
    if (reasons.isNotEmpty) {
      buf.writeln("Signals:");
      for (final r in reasons) {
        buf.writeln("  • ${_label(r)}");
      }
    }
    if (alternativeLabel != top2Label) {
      buf.writeln("Best confusable: $alternativeLabel");
    }
    return buf.toString().trim();
  }

  String _label(AmbiguityReason r) {
    switch (r) {
      case AmbiguityReason.lowAbsoluteConfidence:
        return "Low absolute confidence (< 70%)";
      case AmbiguityReason.smallConfidenceGap:
        return "Small gap between top-2 (< 15 pp)";
      case AmbiguityReason.knownConfusionPair:
        return "Confusable class present: $top1Label ↔ $alternativeLabel";
      case AmbiguityReason.signatureKeywordMissing:
        return "Signature keyword for '$top1Label' absent from input";
    }
  }
}