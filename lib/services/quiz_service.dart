// ─────────────────────────────────────────────────────────────────────────────
// quiz_service.dart
// Handles question loading. Fetches from Supabase if available; falls back to
// built-in sample questions so the quiz works offline / during development.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz.dart';

class QuizService {
  final SupabaseClient _supabase;

  QuizService(this._supabase);

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Fetch questions for a given lesson category id.
  /// Pass [difficulty] to filter by level, or leave null for all difficulties.
  /// Pass [limit] to cap the number of questions returned.
  Future<List<QuizQuestion>> getQuestions({
    required int lessonId,
    QuizDifficulty? difficulty,
    int limit = 10,
  }) async {
    try {
      // Filter by lesson_id first, then optionally by difficulty, then limit last
      var query = _supabase
          .from('quiz_questions')
          .select()
          .eq('lesson_id', lessonId);

      final filteredQuery = difficulty != null
          ? query.eq('difficulty', difficulty.name)
          : query;

      final response = await filteredQuery.limit(limit);
      final questions = response
          .map((json) => QuizQuestion.fromJson(json as Map<String, dynamic>))
          .toList();

      if (questions.isNotEmpty) {
        questions.shuffle();
        return questions;
      }

      // Supabase returned 0 rows — fall back to built-in sample data
      return _sampleQuestions(lessonId: lessonId, limit: limit);
    } catch (e) {
      print('QuizService: exception, falling back to sample questions: $e');
      return _sampleQuestions(lessonId: lessonId, limit: limit);
    }
  }

  /// Fetch all available quiz categories (for a browse/select screen).
  Future<List<String>> getCategories() async {
    try {
      final response = await _supabase
          .from('quiz_questions')
          .select('category')
          .order('category');

      final raw = response.map((r) => r['category'] as String).toList();
      return raw.toSet().toList(); // deduplicate
    } catch (e) {
      return ['Burns', 'CPR', 'Choking', 'Fractures', 'Bleeding'];
    }
  }

  // ── Supabase table schema reference ───────────────────────────────────────
  //
  //  CREATE TABLE quiz_questions (
  //    id            SERIAL PRIMARY KEY,
  //    lesson_id     INT NOT NULL REFERENCES lessons(id),
  //    category      TEXT NOT NULL,
  //    question      TEXT NOT NULL,
  //    options       JSONB NOT NULL,   -- ["option a", "option b", ...]
  //    correct_index INT NOT NULL,
  //    explanation   TEXT NOT NULL,
  //    difficulty    TEXT NOT NULL DEFAULT 'beginner'
  //  );
  //
  // ──────────────────────────────────────────────────────────────────────────

  // ── Sample / fallback data ─────────────────────────────────────────────────

  List<QuizQuestion> _sampleQuestions({
    required int lessonId,
    required int limit,
  }) {
    const all = [
      QuizQuestion(
        id: 1,
        category: 'Burns',
        question: 'What is the first step when treating a minor thermal burn?',
        options: [
          'Apply butter or oil to soothe the skin',
          'Run cool (not cold) water over the burn for 10–20 minutes',
          'Pop any blisters to release pressure',
          'Wrap tightly with a dry bandage immediately',
        ],
        correctIndex: 1,
        explanation:
        'Cool running water reduces heat in the tissue and limits damage. '
            'Avoid ice, butter, or toothpaste — these worsen the injury.',
        difficulty: QuizDifficulty.beginner,
      ),
      QuizQuestion(
        id: 2,
        category: 'CPR',
        question:
        'For an unresponsive adult with no breathing, what is the correct '
            'compression-to-breath ratio?',
        options: ['15:2', '30:2', '20:1', '5:1'],
        correctIndex: 1,
        explanation:
        'Current AHA/ERC guidelines recommend 30 chest compressions '
            'followed by 2 rescue breaths for adult CPR.',
        difficulty: QuizDifficulty.intermediate,
      ),
      QuizQuestion(
        id: 3,
        category: 'Choking',
        question:
        'A conscious adult is choking and cannot speak or cough. '
            'What should you do first?',
        options: [
          'Give 5 back blows between the shoulder blades',
          'Call emergency services immediately',
          'Perform a finger sweep of the mouth',
          'Start CPR compressions',
        ],
        correctIndex: 0,
        explanation:
        'The sequence is 5 back blows followed by 5 abdominal thrusts '
            '(Heimlich). Call EMS only if the blockage cannot be cleared.',
        difficulty: QuizDifficulty.intermediate,
      ),
      QuizQuestion(
        id: 4,
        category: 'Fractures',
        question:
        'Which sign most strongly suggests a bone fracture rather than a sprain?',
        options: [
          'Mild swelling around the joint',
          'Visible deformity or unnatural angle of the limb',
          'Bruising appearing 24 hours later',
          'Pain that reduces with rest',
        ],
        correctIndex: 1,
        explanation:
        'A visible deformity or unnatural angle strongly indicates a '
            'fracture. Sprains typically show swelling and bruising without deformity.',
        difficulty: QuizDifficulty.beginner,
      ),
      QuizQuestion(
        id: 5,
        category: 'Bleeding',
        question:
        'When applying direct pressure to a severe wound, how long should '
            'you maintain pressure before checking?',
        options: [
          '30 seconds',
          '1 minute',
          'At least 10 minutes',
          '5 minutes',
        ],
        correctIndex: 2,
        explanation:
        'Maintain firm, uninterrupted pressure for at least 10 minutes. '
            'Lifting the dressing resets clot formation and prolongs bleeding.',
        difficulty: QuizDifficulty.advanced,
      ),

      // ── Choking (lessonId 2) ───────────────────────────────────────────────
      QuizQuestion(
        id: 6,
        category: 'Mild Choking',
        question: 'What is the recommended first response for a conscious adult with mild choking?',
        options: [
          'Perform abdominal thrusts immediately',
          'Encourage the person to keep coughing',
          'Slap the back 5 times hard',
          'Call emergency services right away',
        ],
        correctIndex: 1,
        explanation:
        'If the person can cough forcefully, encourage continued coughing. '
            'A strong cough is more effective than back blows at this stage.',
        difficulty: QuizDifficulty.beginner,
      ),
      QuizQuestion(
        id: 7,
        category: 'Severe Choking',
        question: 'What is the correct sequence for a conscious adult with severe choking?',
        options: [
          '5 abdominal thrusts, then call EMS',
          '5 back blows, then 5 abdominal thrusts — repeat until cleared',
          'Finger sweep the mouth immediately',
          'Lay the person down and begin CPR',
        ],
        correctIndex: 1,
        explanation:
        'Give 5 firm back blows between the shoulder blades, then 5 abdominal '
            'thrusts. Alternate and repeat until the object is expelled or the person loses consciousness.',
        difficulty: QuizDifficulty.intermediate,
      ),
      QuizQuestion(
        id: 8,
        category: 'Unconscious Choking',
        question: 'When a choking victim becomes unconscious, what should you do first?',
        options: [
          'Continue abdominal thrusts on the floor',
          'Lower them safely to the ground and call EMS, then begin CPR',
          'Perform a blind finger sweep',
          'Give rescue breaths only',
        ],
        correctIndex: 1,
        explanation:
        'Lower the person carefully, call emergency services, then begin CPR. '
            'Each time you open the airway to give breaths, look for the object before ventilating.',
        difficulty: QuizDifficulty.advanced,
      ),
      QuizQuestion(
        id: 9,
        category: 'Mild Choking',
        question: 'Which sign indicates mild choking rather than severe choking?',
        options: [
          'The person cannot speak at all',
          'The person has a silent cough',
          'The person can cough loudly and speak',
          'The person is turning blue',
        ],
        correctIndex: 2,
        explanation:
        'Mild choking means the airway is only partially blocked — '
            'the person can still cough forcefully, speak, and breathe, unlike severe choking.',
        difficulty: QuizDifficulty.beginner,
      ),
    ];

    // Filter by lessonId if possible, otherwise return a mix
    final filtered = lessonId == 2
        ? all.where((q) => q.id >= 6).toList()
        : all.where((q) => q.id <= 5).toList();

    final list = filtered.isNotEmpty ? filtered : [...all];
    list.shuffle();
    return list.take(limit).toList();
  }
}