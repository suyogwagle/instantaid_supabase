// lib/services/hybrid_intent_classifier.dart
//
// AMBIGUITY / CONTEXT POLICY:
//   Skip context gathering when hybrid keyword patterns OR ambiguity-detector
//   signature keywords match the classified intent.
//   Only enter context gathering on the ML path when neither keyword source hits.

import 'package:flutter/material.dart';
import 'injury_classifier.dart';
import 'context_gatherer.dart';
import 'ambiguity_detector.dart';

class HybridIntentClassifier {
  final InjuryClassifier _mlClassifier;

  HybridIntentClassifier(this._mlClassifier);

  static final Map<String, List<RegExp>> keywordPatterns = {
    "snake_bite": [
      RegExp(r"\b(snake|serpent|viper|cobra).{0,10}(bite|bitten|bit)\b",
          caseSensitive: false),
      RegExp(r"सर्प(को)?\s*टोक"),
    ],
    "burn": [
      RegExp(r"\b(burn|burnt|burned|scald).{0,15}(fire|flame|hot|boiling)\b",
          caseSensitive: false),
      RegExp(r"\b(fire|flame|boiling\s*water|hot\s*oil).{0,15}(burn|scald)\b",
          caseSensitive: false),
      RegExp(r"जल(न|िएको|ेको)"),
    ],
    "fracture": [
      RegExp(r"\b(fracture|broken\s*bone|bone\s*broke)\b",
          caseSensitive: false),
      RegExp(r"हड्डी\s*भाँचि"),
    ],
    "choking": [
      RegExp(r"\b(choking|choke|can'?t\s*swallow|food\s*stuck)\b",
          caseSensitive: false),
      RegExp(r"घाँटी\s*अड्क"),
    ],
    "cardiac_attack": [
      RegExp(r"\b(heart\s*attack|cardiac\s*arrest|chest\s*pain)\b",
          caseSensitive: false),
      RegExp(r"मुटु\s*(आक्रमण|दौरा|ह्याट्याक)"),
    ],
    "wound": [
      RegExp(r"\b(deep\s*cut|laceration|stab|gash|bleeding\s*wound)\b",
          caseSensitive: false),
      RegExp(r"गहिरो\s*घाउ|धेरै\s*रगत"),
    ],
    "poisoning": [
      RegExp(r"\b(swallowed\s*poison|drank\s*(bleach|acid|chemical)|overdose)\b",
          caseSensitive: false),
      RegExp(r"विष\s*खायो|ओभरडोज"),
    ],
    "altitude_sickness": [
      RegExp(
          r"\b(altitude\s*sickness|mountain\s*sickness|AMS|sick\s*(at|on)\s*(mountain|trek))\b",
          caseSensitive: false),
      RegExp(r"उचाइ\s*रोग|पहाडमा\s*बिरामी"),
    ],
    "road_accident": [
      RegExp(r"\b(road\s*accident|car\s*crash|bike\s*accident|hit\s*by\s*(car|vehicle|truck))\b",
          caseSensitive: false),
      RegExp(r"सडक\s*दुर्घटना|गाडीले\s*ठोक्यो"),
    ],
    "electric_shock": [
      RegExp(r"\b(electric(al)?\s*shock|electrocuted?|touched\s*(live\s*wire|socket))\b",
          caseSensitive: false),
      RegExp(r"बिजुली(को)?\s*झटका|करेन्ट\s*लाग्यो"),
    ],
    "allergic_reaction": [
      RegExp(r"\b(anaphylaxis|severe\s*allerg|epipen|throat\s*swelling)\b",
          caseSensitive: false),
      RegExp(r"एलर्जी\s*रिएक्शन|घाँटी\s*सुन्नियो"),
    ],
    "common_cold": [
      RegExp(r"\b(common\s*cold|runny\s*nose|blocked\s*nose|sneezing)\b",
          caseSensitive: false),
      RegExp(r"रुघा|नाक\s*बग्यो|हाछ्युँ"),
    ],
  };

  // ── Main entry point ───────────────────────────────────────────────────
  //
  // Returns:
  //   "intent"           String
  //   "confidence"       double
  //   "method"           String
  //   "needs_context"    bool   ← true for all ML-path results
  //   "ambiguity_report" AmbiguityReport?

  Future<Map<String, dynamic>> classifyWithAmbiguityCheck(
      String userText) async {

    // ── Step 1: Keyword fast path ────────────────────────────────────────
    // Any hybrid keyword pattern match is trusted — go straight to first aid.
    final kwResult = _tryKeywordMatching(userText);
    final kwMatches = kwResult["matches"] as int;
    if (kwMatches > 0) {
      debugPrint("✅ Keyword hit: ${kwResult['intent']} — skipping ML + context");
      return {
        ...kwResult,
        "confidence"       : 0.95,
        "needs_context"    : false,
        "ambiguity_report" : null,
      };
    }

    // ── Step 2: ML inference (single call, cached) ───────────────────────
    final mlResult = await _mlClassifier.classifyFull(userText);

    if (mlResult == null) {
      // Model unavailable — fall back to keyword if we have one.
      if (kwMatches > 0) {
        debugPrint("⚠️ ML unavailable — keyword fallback: ${kwResult['intent']}");
        return {
          ...kwResult,
          "confidence"       : 0.95,
          "needs_context"    : false,
          "ambiguity_report" : null,
        };
      }
      return {
        "intent"           : "unknown",
        "confidence"       : 0.0,
        "method"           : "none",
        "needs_context"    : false,
        "ambiguity_report" : null,
      };
    }

    // ── Step 3: Build ambiguity report (no extra inference) ──────────────
    final report = AmbiguityDetector.evaluate(
      result  : mlResult,
      userText: userText,
    );

    // Log what the model actually thinks across all 12 classes.
    debugPrint("🔍 ML top-1: ${report.top1Label} "
        "${(report.top1Confidence * 100).toStringAsFixed(1)}%  |  "
        "top-2: ${report.top2Label} "
        "${(report.top2Confidence * 100).toStringAsFixed(1)}%  |  "
        "gap: ${(report.gap * 100).toStringAsFixed(1)}pp  |  "
        "best confusable: ${report.alternativeLabel}");

    // ── Step 4: ML path — gather context only when no keyword evidence ───
    final top1 = report.top1Label;
    final hasKeywordSupport = _matchesKeywordForIntent(userText, top1) ||
        AmbiguityDetector.hasSignatureKeywords(top1, userText);

    if (hasKeywordSupport) {
      debugPrint("✅ Keyword/signature support for $top1 — skipping context");
      return {
        "intent"           : top1,
        "confidence"       : report.top1Confidence,
        "ml_confidence"    : report.top1Confidence,
        "top2_label"       : report.top2Label,
        "top2_confidence"  : report.top2Confidence,
        "gap"              : report.gap,
        "method"           : "ml_keyword_supported",
        "ambiguity_report" : report,
        "needs_context"    : false,
      };
    }

    debugPrint("🔍 No keyword hit — gathering context for $top1");
    return {
      "intent"           : top1,
      "confidence"       : report.top1Confidence,
      "ml_confidence"    : report.top1Confidence,
      "top2_label"       : report.top2Label,
      "top2_confidence"  : report.top2Confidence,
      "gap"              : report.gap,
      "method"           : "ml_needs_context",
      "ambiguity_report" : report,
      "needs_context"    : true,
    };
  }

  // ── Backward-compatible alias ──────────────────────────────────────────

  Future<Map<String, dynamic>> classifyIntent(String userText) =>
      classifyWithAmbiguityCheck(userText);

  // ── Context-enriched re-classification ────────────────────────────────
  // Called after context gathering is complete.
  // Runs a fresh inference on the enriched string and returns a final,
  // trustworthy result.  needs_context is false on the result.

  Future<Map<String, dynamic>> classifyWithContext({
    required String originalText,
    required String candidateIntent,
    required List<String> contextKeys,
    required List<String> contextValues,
    required bool isNepali,
  }) async {
    final enriched = ContextGatherer.buildEnrichedInput(
      originalText  : originalText,
      contextKeys   : contextKeys,
      contextValues : contextValues,
      isNepali      : isNepali,
    );

    debugPrint("🔁 Re-classifying enriched input:\n   $enriched");

    // Fresh inference on the richer string (different cache key).
    final mlResult = await _mlClassifier.classifyFull(enriched);

    if (mlResult == null) {
      return {
        "intent"          : candidateIntent,
        "confidence"      : 0.0,
        "method"          : "context_enriched_ml_unavailable",
        "enriched_text"   : enriched,
        "original_intent" : candidateIntent,
        "intent_changed"  : false,
        "needs_context"   : false,
        "ambiguity_report": null,
      };
    }

    // Run ambiguity check on enriched result too, just for logging.
    final report = AmbiguityDetector.evaluate(
      result  : mlResult,
      userText: enriched,
    );

    debugPrint("🔁 Enriched result: ${mlResult.top1Label} "
        "${(mlResult.top1Confidence * 100).toStringAsFixed(1)}%  "
        "(was: $candidateIntent)  "
        "changed: ${mlResult.top1Label != candidateIntent}");

    return {
      "intent"           : mlResult.top1Label,
      "confidence"       : mlResult.top1Confidence,
      "ml_confidence"    : mlResult.top1Confidence,
      "top2_label"       : mlResult.top2Label,
      "top2_confidence"  : mlResult.top2Confidence,
      "method"           : "context_enriched",
      "enriched_text"    : enriched,
      "original_intent"  : candidateIntent,
      "intent_changed"   : mlResult.top1Label != candidateIntent,
      "ambiguity_report" : report,
      "needs_context"    : false,  // ← done, no more context rounds
    };
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  bool _matchesKeywordForIntent(String text, String intent) {
    final patterns = keywordPatterns[intent];
    if (patterns == null) return false;
    return patterns.any((p) => p.hasMatch(text));
  }

  Map<String, dynamic> _tryKeywordMatching(String text) {
    for (final entry in keywordPatterns.entries) {
      int matches = 0;
      for (final pattern in entry.value) {
        if (pattern.hasMatch(text)) matches++;
      }
      if (matches > 0) {
        return {
          "intent"    : entry.key,
          "confidence": (matches / entry.value.length).clamp(0.5, 1.0),
          "method"    : "keyword",
          "matches"   : matches,
        };
      }
    }
    return {
      "intent"    : "unknown",
      "confidence": 0.0,
      "method"    : "keyword",
      "matches"   : 0,
    };
  }

  String getDisambiguationMessage(Map<String, dynamic> result,
      {bool isNepali = false}) {
    if ((result["confidence"] as double) < 0.5) {
      return isNepali
          ? "मलाई पक्का छैन। के तपाईं थप विवरण दिन सक्नुहुन्छ?\nके कसैलाई चोट लागेको छ? के भयो?"
          : "I'm not completely sure. Could you provide more details?\nWhat happened exactly?";
    }
    return "";
  }
}