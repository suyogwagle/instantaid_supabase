// lib/services/context_gatherer.dart
//
// ALL questions are open-ended — no yes/no.
// The user's free-text answer becomes a rich phrase that the model
// can actually learn from when concatenated to the original input.
//
// Example enriched string:
//   "My heart is beating fast.
//    current location: at home sitting on the couch.
//    symptoms: chest tightness and left arm pain."
//   → model now has enough context to say cardiac_attack with high confidence.

class ContextQuestion {
  final String questionEn;
  final String questionNp;

  /// Short label prepended when building the enriched string.
  /// e.g. "current location" → "current location: at home sitting on the couch"
  final String contextKeyEn;
  final String contextKeyNp;

  const ContextQuestion({
    required this.questionEn,
    required this.questionNp,
    required this.contextKeyEn,
    required this.contextKeyNp,
  });
}

class ContextGatherer {
  static const int maxContextRounds = 2;

  // ── Question bank ────────────────────────────────────────────────────────
  // Rules for every question:
  //   1. Open-ended — never answerable with just "yes" or "no".
  //   2. Short enough to read in a panic.
  //   3. The expected answer is a descriptive phrase that adds
  //      discriminating tokens to the enriched input.

  static const Map<String, List<ContextQuestion>> _questionBank = {

    // ── cardiac_attack ── confusable with: altitude_sickness, anxiety ──────
    "cardiac_attack": [
      ContextQuestion(
        questionEn: "Where are you right now, and what were you doing when this started?",
        questionNp: "तपाईं अहिले कहाँ हुनुहुन्छ, र यो सुरु हुँदा के गर्दै हुनुहुन्थ्यो?",
        contextKeyEn: "current location and activity",
        contextKeyNp: "हालको स्थान र गतिविधि",
      ),
      ContextQuestion(
        questionEn: "Describe all your symptoms — chest, arms, jaw, breathing, sweating?",
        questionNp: "सबै लक्षण बताउनुहोस् — छाती, हात, जबडा, सास, पसिना?",
        contextKeyEn: "full symptoms",
        contextKeyNp: "पूरा लक्षणहरू",
      ),
    ],

    // ── altitude_sickness ── confusable with: cardiac_attack, common_cold ──
    "altitude_sickness": [
      ContextQuestion(
        questionEn: "Where exactly are you right now — describe your location and surroundings?",
        questionNp: "तपाईं अहिले ठ्याक्कै कहाँ हुनुहुन्छ — आफ्नो स्थान र वरपरको वर्णन गर्नुहोस्?",
        contextKeyEn: "current location",
        contextKeyNp: "हालको स्थान",
      ),
      ContextQuestion(
        questionEn: "Describe all your symptoms in detail — head, stomach, breathing, vision?",
        questionNp: "आफ्ना सबै लक्षण विस्तारमा बताउनुहोस् — टाउको, पेट, सास, दृष्टि?",
        contextKeyEn: "symptoms detail",
        contextKeyNp: "लक्षणहरूको विवरण",
      ),
    ],

    // ── wound ── confusable with: road_accident, fracture ──────────────────
    "wound": [
      ContextQuestion(
        questionEn: "How exactly did this happen, and where on the body is the wound?",
        questionNp: "यो ठ्याक्कै कसरी भयो, र शरीरको कुन भागमा घाउ छ?",
        contextKeyEn: "injury cause and location",
        contextKeyNp: "चोटको कारण र स्थान",
      ),
      ContextQuestion(
        questionEn: "Describe the wound — how deep, how much bleeding, any bone visible?",
        questionNp: "घाउको वर्णन गर्नुहोस् — कति गहिरो, कति रगत, हड्डी देखिएको छ?",
        contextKeyEn: "wound description",
        contextKeyNp: "घाउको विवरण",
      ),
    ],

    // ── burn ── confusable with: electric_shock ─────────────────────────────
    "burn": [
      ContextQuestion(
        questionEn: "What caused the burn — describe what happened exactly?",
        questionNp: "जलन कसरी भयो — के भयो ठ्याक्कै बताउनुहोस्?",
        contextKeyEn: "burn cause",
        contextKeyNp: "जलनको कारण",
      ),
      ContextQuestion(
        questionEn: "Where on the body is the burn, and describe what the skin looks like now?",
        questionNp: "शरीरको कुन भागमा जलेको छ, र अहिले छाला कस्तो देखिन्छ?",
        contextKeyEn: "burn location and appearance",
        contextKeyNp: "जलनको स्थान र देखावट",
      ),
    ],

    // ── snake_bite ── confusable with: wound ───────────────────────────────
    "snake_bite": [
      ContextQuestion(
        questionEn: "Describe what happened — where were you and what did you see or feel?",
        questionNp: "के भयो बताउनुहोस् — तपाईं कहाँ थिनुहुन्थ्यो र के देख्नुभयो वा महसुस गर्नुभयो?",
        contextKeyEn: "incident description",
        contextKeyNp: "घटनाको विवरण",
      ),
      ContextQuestion(
        questionEn: "Where on the body is the bite, and describe any swelling, pain, or marks?",
        questionNp: "शरीरको कुन भागमा टोकेको छ, र सुन्निनु, दुखाइ वा दागको वर्णन गर्नुहोस्?",
        contextKeyEn: "bite location and symptoms",
        contextKeyNp: "टोकाइको स्थान र लक्षण",
      ),
    ],

    // ── choking ── confusable with: allergic_reaction ──────────────────────
    "choking": [
      ContextQuestion(
        questionEn: "What were you eating or doing just before this started?",
        questionNp: "यो सुरु हुनुभन्दा अगाडि के खाँदै वा गर्दै हुनुहुन्थ्यो?",
        contextKeyEn: "activity before choking",
        contextKeyNp: "घाँटी अड्किनुअघिको गतिविधि",
      ),
      ContextQuestion(
        questionEn: "Describe what the person can or cannot do — speak, cough, breathe?",
        questionNp: "व्यक्ति के गर्न सक्छन् वा सक्दैनन् बताउनुहोस् — बोल्न, खोक्न, सास फेर्न?",
        contextKeyEn: "current breathing ability",
        contextKeyNp: "हालको सास फेर्ने क्षमता",
      ),
    ],

    // ── allergic_reaction ── confusable with: common_cold, choking ─────────
    "allergic_reaction": [
      ContextQuestion(
        questionEn: "What did the person eat, touch, or get stung by before this started?",
        questionNp: "यो सुरु हुनुभन्दा अगाडि व्यक्तिले के खानुभयो, छोनुभयो, वा के ले टोक्यो?",
        contextKeyEn: "trigger before reaction",
        contextKeyNp: "प्रतिक्रियाअघिको कारण",
      ),
      ContextQuestion(
        questionEn: "Describe all visible symptoms — skin, face, throat, breathing?",
        questionNp: "सबै देखिने लक्षणहरू बताउनुहोस् — छाला, अनुहार, घाँटी, सास?",
        contextKeyEn: "visible symptoms",
        contextKeyNp: "देखिने लक्षणहरू",
      ),
    ],

    // ── poisoning ── confusable with: allergic_reaction ────────────────────
    "poisoning": [
      ContextQuestion(
        questionEn: "What exactly was swallowed, inhaled, or touched — describe the substance?",
        questionNp: "ठ्याक्कै के निलियो, सास लिइयो, वा छोइयो — पदार्थको वर्णन गर्नुहोस्?",
        contextKeyEn: "substance description",
        contextKeyNp: "पदार्थको विवरण",
      ),
      ContextQuestion(
        questionEn: "How long ago did this happen, and describe any symptoms now?",
        questionNp: "यो कति समय अगाडि भयो, र अहिले कुनै लक्षण छन् भने बताउनुहोस्?",
        contextKeyEn: "time elapsed and current symptoms",
        contextKeyNp: "बितेको समय र हालका लक्षण",
      ),
    ],

    // ── road_accident ── confusable with: wound, fracture ──────────────────
    "road_accident": [
      ContextQuestion(
        questionEn: "Describe what happened — what type of vehicle or collision was involved?",
        questionNp: "के भयो बताउनुहोस् — कस्तो सवारी वा ठोक्किने घटना थियो?",
        contextKeyEn: "accident description",
        contextKeyNp: "दुर्घटनाको विवरण",
      ),
      ContextQuestion(
        questionEn: "Describe the injuries — where on the body and how severe do they look?",
        questionNp: "चोटको वर्णन गर्नुहोस् — शरीरको कुन भागमा र कति गम्भीर देखिन्छ?",
        contextKeyEn: "injury description",
        contextKeyNp: "चोटको विवरण",
      ),
    ],

    // ── electric_shock ── confusable with: burn ─────────────────────────────
    "electric_shock": [
      ContextQuestion(
        questionEn: "Describe what happened — what did the person touch or come near?",
        questionNp: "के भयो बताउनुहोस् — व्यक्तिले के छोयो वा नजिक गए?",
        contextKeyEn: "shock incident description",
        contextKeyNp: "झटकाको घटनाको विवरण",
      ),
      ContextQuestion(
        questionEn: "Describe the person's condition right now — conscious, breathing, any burns?",
        questionNp: "अहिले व्यक्तिको अवस्था बताउनुहोस् — होस, सास, जलन भएको छ?",
        contextKeyEn: "current condition",
        contextKeyNp: "हालको अवस्था",
      ),
    ],

    // ── fracture ── confusable with: wound, road_accident ──────────────────
    "fracture": [
      ContextQuestion(
        questionEn: "How did this happen, and which part of the body is injured?",
        questionNp: "यो कसरी भयो, र शरीरको कुन भाग चोटिएको छ?",
        contextKeyEn: "fracture cause and location",
        contextKeyNp: "हड्डी भाँचिनुको कारण र स्थान",
      ),
      ContextQuestion(
        questionEn: "Describe what you see — shape of the limb, swelling, skin color, movement?",
        questionNp: "के देख्नुहुन्छ बताउनुहोस् — अंगको आकार, सुन्निनु, छालाको रङ, हिलाउन सकिन्छ?",
        contextKeyEn: "limb appearance",
        contextKeyNp: "अंगको देखावट",
      ),
    ],

    // ── common_cold ── confusable with: allergic_reaction, altitude_sickness
    "common_cold": [
      ContextQuestion(
        questionEn: "How long have you had these symptoms, and describe everything you feel?",
        questionNp: "कति समयदेखि यी लक्षणहरू छन्, र महसुस गरेका सबै कुरा बताउनुहोस्?",
        contextKeyEn: "symptom duration and description",
        contextKeyNp: "लक्षणको अवधि र विवरण",
      ),
    ],
  };

  // ── Public API ────────────────────────────────────────────────────────────

  static List<ContextQuestion> getQuestionsFor(String intent) {
    final questions = _questionBank[intent] ?? [];
    return questions.take(maxContextRounds).toList();
  }

  /// Returns a blended set of context questions for a primary intent and an
  /// optional confusable alternative intent.
  ///
  /// Policy:
  /// - If no alternative is provided (or it's the same as primary), behave like
  ///   [getQuestionsFor].
  /// - If both have questions, prefer asking one from each (up to
  ///   [maxContextRounds]) so the enriched input captures distinguishing tokens.
  static List<ContextQuestion> getQuestionsForPair({
    required String primaryIntent,
    String? alternativeIntent,
  }) {
    if (alternativeIntent == null || alternativeIntent == primaryIntent) {
      return getQuestionsFor(primaryIntent);
    }

    final primary = _questionBank[primaryIntent] ?? const <ContextQuestion>[];
    final alt = _questionBank[alternativeIntent] ?? const <ContextQuestion>[];

    if (primary.isEmpty && alt.isEmpty) return [];
    if (primary.isEmpty) return alt.take(maxContextRounds).toList();
    if (alt.isEmpty) return primary.take(maxContextRounds).toList();

    final combined = <ContextQuestion>[];
    combined.add(primary.first);
    if (combined.length < maxContextRounds) {
      combined.add(alt.first);
    }
    return combined.take(maxContextRounds).toList();
  }

  /// Builds the enriched input string.
  static String buildEnrichedInput({
    required String originalText,
    required List<String> contextKeys,
    required List<String> contextValues,
    required bool isNepali,
  }) {
    assert(contextKeys.length == contextValues.length);
    String clean(String s) {
      // Normalize whitespace and strip noisy punctuation that can
      // destabilize the classifier (e.g. ", ." or "..., ,").
      var out = s.replaceAll(RegExp(r"\s+"), " ").trim();
      out = out.replaceAll(RegExp(r"^[\s,.;:]+"), "");
      out = out.replaceAll(RegExp(r"[\s,.;:]+$"), "");
      return out.trim();
    }

    final base = clean(originalText);
    final buffer = StringBuffer(base);
    for (int i = 0; i < contextKeys.length; i++) {
      final key = clean(contextKeys[i]);
      final value = clean(contextValues[i]);
      if (value.isEmpty) continue;

      // Separator: only add a period if the buffer doesn't already end with one.
      final current = buffer.toString();
      if (current.isNotEmpty && !RegExp(r"[.!?]$").hasMatch(current)) {
        buffer.write('.');
      }
      buffer.write(' ');

      // Include a short key label so the model can learn from structure,
      // but keep it compact and consistent across languages.
      if (key.isNotEmpty) {
        buffer.write(key);
        buffer.write(': ');
      }
      buffer.write(value);
    }
    final finalText = buffer.toString().trim();
    if (finalText.isEmpty) return "";
    return RegExp(r"[.!?]$").hasMatch(finalText) ? finalText : '$finalText.';
  }

  static bool isConfidenceAcceptable(double confidence) => confidence >= 0.55;
}