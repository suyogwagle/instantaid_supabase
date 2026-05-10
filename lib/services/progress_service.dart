// Tracks which lessons a user has completed and decides whether they are
// eligible to take the quiz for a given lesson category.

import 'package:supabase_flutter/supabase_flutter.dart';

class LessonCompletion {
  final int lessonId;
  final String subcategory;
  final DateTime completedAt;

  const LessonCompletion({
    required this.lessonId,
    required this.subcategory,
    required this.completedAt,
  });

  factory LessonCompletion.fromJson(Map<String, dynamic> json) {
    return LessonCompletion(
      lessonId:    json['lesson_id'] as int,
      subcategory: json['subcategory'] as String,
      completedAt: DateTime.parse(json['completed_at'] as String),
    );
  }
}

// Result returned to the UI so it knows exactly what's missing
class QuizEligibility {
  final bool isEligible;
  final int completedCount;
  final int totalRequired;
  final List<String> missingSubcategories;

  const QuizEligibility({
    required this.isEligible,
    required this.completedCount,
    required this.totalRequired,
    required this.missingSubcategories,
  });

  double get progressFraction =>
      totalRequired == 0 ? 0 : completedCount / totalRequired;

  int get progressPercent => (progressFraction * 100).round();
}

class ProgressService {
  final SupabaseClient _supabase;

  ProgressService(this._supabase);

  // ── Mark a single lesson+subcategory as complete ──
  Future<void> markComplete({
    required int lessonId,
    required String subcategory,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('lesson_progress').upsert(
      {
        'user_id':    userId,
        'lesson_id':  lessonId,
        'subcategory': subcategory,
      },
      onConflict: 'user_id, lesson_id, subcategory',
    );
  }

  // ── Fetch all completed lessons for one category ──

  Future<List<LessonCompletion>> getCompletedLessons({
    required int lessonId,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('lesson_progress')
        .select()
        .eq('user_id', userId)
        .eq('lesson_id', lessonId);

    return response
        .map((json) => LessonCompletion.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ── Core gate: check if user can take the quiz ──

  Future<QuizEligibility> checkQuizEligibility({
    required int lessonId,
    required List<String> requiredSubcategories,
  }) async {
    final completed = await getCompletedLessons(lessonId: lessonId);

    // Normalise both sides to lowercase snake_case so keys always match
    // regardless of how they were originally stored or defined.
    final completedKeys = completed
        .map((c) => _normalise(c.subcategory))
        .toSet();
    final requiredKeys = requiredSubcategories
        .map(_normalise)
        .toList();

    // remove once keys are confirmed to match in production
    print('[ProgressService] completed keys  : $completedKeys');
    print('[ProgressService] required keys   : ${requiredKeys.take(3)}... (${requiredKeys.length} total)');
    print('[ProgressService] matched         : ${completedKeys.intersection(requiredKeys.toSet()).length}/${requiredKeys.length}');

    final missing = requiredKeys
        .where((s) => !completedKeys.contains(s))
        .toList();

    return QuizEligibility(
      isEligible:           missing.isEmpty,
      completedCount:       completedKeys.intersection(requiredKeys.toSet()).length,
      totalRequired:        requiredKeys.length,
      missingSubcategories: missing,
    );
  }

  // Normalise to lowercase snake_case: 'Thermal Burn' → 'thermal_burn'
  String _normalise(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');

  // ── Convenience: check progress percentage only (for progress bars) ──

  Future<double> getLessonProgressFraction({
    required int lessonId,
    required List<String> requiredSubcategories,
  }) async {
    final eligibility = await checkQuizEligibility(
      lessonId:             lessonId,
      requiredSubcategories: requiredSubcategories,
    );
    return eligibility.progressFraction;
  }
}