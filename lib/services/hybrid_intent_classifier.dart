
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'injury_classifier.dart';

/// Hybrid Intent Classifier: Fast keywords + ML fallback
class HybridIntentClassifier {
  final InjuryClassifier _mlClassifier;

  HybridIntentClassifier(this._mlClassifier);

  /// High-confidence keyword patterns
  static final Map<String, List<RegExp>> keywordPatterns = {
    "snake_bite": [
      RegExp(r"\b(snake|serpent|viper|cobra).{0,10}(bite|bitten|bit)\b", caseSensitive: false),  // More flexible
      RegExp(r"सर्प(को)?\s*टोक"),
    ],

    "burn": [
      RegExp(r"\b(fire\s*(burn|burnt|burned|scald))\b", caseSensitive: false),
      RegExp(r"\b(fire|flame|hot\s*(water|oil))\b", caseSensitive: false),
      RegExp(r"जल(न|िएको|ेको)"),
    ],

    "fracture": [
      RegExp(r"\b(fracture|broken\s*bone)\b", caseSensitive: false),
      RegExp(r"हड्डी\s*भाँचि"),
    ],

    "choking": [
      RegExp(r"\b(choking|choke|can'?t\s*swallow)\b", caseSensitive: false),
      RegExp(r"घाँटी\s*अड्क"),
    ],

    "cardiac_attack": [
      RegExp(r"\b(heart\s*attack|cardiac|chest\s*pain)\b", caseSensitive: false),
      RegExp(r"मुटु\s*(आक्रमण|दौरा)"),
    ],

    "wound": [
      RegExp(r"\b(cut|laceration|wound|bleeding|bruise|scratch)\b", caseSensitive: false),
      RegExp(r"घाउ|चोट|रगत"),
    ],

    "poisoning": [
      RegExp(r"\b(poison|toxic|swallowed)\s*(substance|chemical|pills?)\b", caseSensitive: false),
      RegExp(r"विष"),
    ],

    "altitude_sickness": [
      RegExp(r"\b(altitude\s*sickness|mountain\s*sickness)\b", caseSensitive: false),
      RegExp(r"उचाइ\s*रोग"),
    ],

    "road_accident": [
      RegExp(r"\b(road\s*accident|car\s*accident|crash)\b", caseSensitive: false),
      RegExp(r"सडक\s*दुर्घटना"),
    ],

    "electric_shock": [
      RegExp(r"\b(electric(al)?\s*shock|electrocuted?)\b", caseSensitive: false),
      RegExp(r"बिजुली(को)?\s*झटका"),
    ],

    "allergic_reaction": [
      RegExp(r"\b(allergic\s*reaction|allergy|anaphylaxis)\b", caseSensitive: false),
      RegExp(r"एलर्जी"),
    ],

    "common_cold": [
      RegExp(r"\b(common\s*cold|light fever|flu|cough|runny\s*nose)\b", caseSensitive: false),
      RegExp(r"रुघा|खोकी"),
    ],
  };

  /// Main classification method
  Future<Map<String, dynamic>> classifyIntent(String userText) async {
    debugPrint("🔍 Classifying: $userText");

    // STEP 1: Try fast keyword matching
    final keywordResult = _tryKeywordMatching(userText);
    if (keywordResult["confidence"] >= 0.8) {
      debugPrint(" High-confidence keyword match: ${keywordResult['intent']}");
      return keywordResult;
    }

    // STEP 2: Fall back to ML model
    debugPrint("📊 Using ML classifier...");
    final mlPrediction = await _mlClassifier.predict(userText);

    // Get actual ML confidence score
    final mlConfidence = await _mlClassifier.getConfidence(userText);
    debugPrint("📊 ML Confidence: ${(mlConfidence * 100).toStringAsFixed(1)}%");

    // Check if ML returned valid result
    if (mlPrediction == "Model not loaded" ||
        mlPrediction == "Prediction failed" ||
        mlPrediction == "Please explain the situation in detail.") {

      // ML failed, use keyword result if available
      if (keywordResult["intent"] != "unknown") {
        debugPrint("⚠️ ML failed, using keyword result");
        return keywordResult;
      }

      // Both failed
      return {
        "intent": "unknown",
        "confidence": 0.0,
        "method": "none",
        "message": mlPrediction,
      };
    }

    // STEP 3: Combine results
    if (keywordResult["intent"] != "unknown") {
      // Both methods found something
      if (keywordResult["intent"] == mlPrediction) {
        // Agreement - USE MAX confidence (not average)
        final maxConfidence = math.max(mlConfidence, keywordResult["confidence"] as double);
        debugPrint("✅ Keyword + ML agree: $mlPrediction (max: ${(maxConfidence * 100).toStringAsFixed(1)}%)");
        return {
          "intent": mlPrediction,
          "confidence": maxConfidence,  // FIXED: Use MAX instead of combined
          "ml_confidence": mlConfidence,
          "keyword_confidence": keywordResult["confidence"],
          "method": "hybrid_agreement"
        };
      } else {
        // Disagreement - prefer ML and use its confidence
        debugPrint("⚠️ Keyword says ${keywordResult['intent']}, ML says $mlPrediction");
        return {
          "intent": mlPrediction,
          "confidence": mlConfidence,  // FIXED: Just use ML confidence as-is
          "ml_confidence": mlConfidence,
          "keyword_confidence": keywordResult["confidence"],
          "method": "ml_primary",
          "keyword_alternative": keywordResult["intent"]
        };
      }
    }

    // STEP 4: Only ML found something - use actual ML confidence
    debugPrint("✅ ML only: $mlPrediction (${(mlConfidence * 100).toStringAsFixed(1)}%)");
    return {
      "intent": mlPrediction,
      "confidence": mlConfidence,
      "ml_confidence": mlConfidence,
      "method": "ml_only"
    };
  }

  /// Fast keyword matching
  Map<String, dynamic> _tryKeywordMatching(String text) {
    for (final entry in keywordPatterns.entries) {
      final intent = entry.key;
      final patterns = entry.value;

      int matches = 0;
      for (final pattern in patterns) {
        if (pattern.hasMatch(text)) {
          matches++;
        }
      }

      if (matches > 0) {
        final confidence = (matches / patterns.length).clamp(0.5, 1.0);
        return {
          "intent": intent,
          "confidence": confidence,
          "method": "keyword",
          "matches": matches
        };
      }
    }

    return {
      "intent": "unknown",
      "confidence": 0.0,
      "method": "keyword",
      "matches": 0
    };
  }

  /// Handle ambiguous results
  String getDisambiguationMessage(Map<String, dynamic> result, {bool isNepali = false}) {
    if (result.containsKey("keyword_alternative")) {
      final intent = result["intent"];
      final alternative = result["keyword_alternative"];

      if (isNepali) {
        return "के तपाईंले '$alternative' भन्न खोज्नुभएको हो, वा '$intent'?";
      } else {
        return "Did you mean '$alternative' or '$intent'?";
      }
    }

    if (result["confidence"] < 0.5) {
      if (isNepali) {
        return "मलाई पक्का छैन। के तपाईं थप विवरण दिन सक्नुहुन्छ?\n"
            "के कसैलाई चोट लागेको छ? के भयो?";
      } else {
        return "I'm not completely sure. Could you provide more details?\n"
            "For example: What happened? Is someone injured?";
      }
    }

    return "";
  }
}