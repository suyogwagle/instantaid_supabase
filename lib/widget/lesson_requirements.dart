// for every lessonId, declares which lesson keys
// must be completed before the user may take the quiz.

// These keys must exactly match what LessonPage passes to
// ProgressService.markComplete(subcategory: ...).

class LessonRequirements {

  // ── Required keys per lesson id ──
  //
  // 1 — Burn Treatment
  //     5 subcategories × 4 degrees × 2 age groups = 40 lessons
  //     Subcategories : thermal_burn | chemical_burn | electrical_burn
  //                     | sunburn | friction_burn
  //     Degrees       : first_degree | second_degree | third_degree | fourth_degree
  //     Age groups    : adult | infant
  //
  // 2 — Choking Response
  //     3 subcategories × 4 types × 2 age groups = 24 lessons
  //     Subcategories : mild_choking | severe_choking | unconscious_choking
  //     Types         : food | foreign_object | liquid | other_circumstances
  //     Age groups    : adult | infant

  static const Map<int, List<String>> _requirements = {

    // ── 1: Burn Treatment ──
    1: [
      // Thermal burn
      'thermal_burn/first_degree/adult',    'thermal_burn/first_degree/child',
      'thermal_burn/second_degree/adult',   'thermal_burn/second_degree/child',
      'thermal_burn/third_degree/adult',    'thermal_burn/third_degree/child',
      'thermal_burn/fourth_degree/adult',   'thermal_burn/fourth_degree/child',
      // Chemical burn
      'chemical_burn/first_degree/adult',   'chemical_burn/first_degree/child',
      'chemical_burn/second_degree/adult',  'chemical_burn/second_degree/child',
      'chemical_burn/third_degree/adult',   'chemical_burn/third_degree/child',
      'chemical_burn/fourth_degree/adult',  'chemical_burn/fourth_degree/child',
      // Electrical burn
      'electrical_burn/first_degree/adult',  'electrical_burn/first_degree/child',
      'electrical_burn/second_degree/adult', 'electrical_burn/second_degree/child',
      'electrical_burn/third_degree/adult',  'electrical_burn/third_degree/child',
      'electrical_burn/fourth_degree/adult', 'electrical_burn/fourth_degree/child',
      // Sunburn
      'sunburn/first_degree/adult',   'sunburn/first_degree/child',
      'sunburn/second_degree/adult',  'sunburn/second_degree/child',
      'sunburn/third_degree/adult',   'sunburn/third_degree/child',
      'sunburn/fourth_degree/adult',  'sunburn/fourth_degree/child',
      // Friction burn
      'friction_burn/first_degree/adult',   'friction_burn/first_degree/child',
      'friction_burn/second_degree/adult',  'friction_burn/second_degree/child',
      'friction_burn/third_degree/adult',   'friction_burn/third_degree/child',
      'friction_burn/fourth_degree/adult',  'friction_burn/fourth_degree/child',
    ],

    // ── 2: Choking Response ──
    2: [
      // Mild choking
      'mild_choking/food/adult',                   'mild_choking/food/infant',
      'mild_choking/foreign_object/adult',          'mild_choking/foreign_object/infant',
      'mild_choking/liquid/adult',                  'mild_choking/liquid/infant',
      'mild_choking/other_circumstances/adult',     'mild_choking/other_circumstances/infant',
      // Severe choking
      'severe_choking/food/adult',                  'severe_choking/food/infant',
      'severe_choking/foreign_object/adult',        'severe_choking/foreign_object/infant',
      'severe_choking/liquid/adult',                'severe_choking/liquid/infant',
      'severe_choking/other_circumstances/adult',   'severe_choking/other_circumstances/infant',
      // Unconscious choking
      'unconscious_choking/food/adult',                 'unconscious_choking/food/infant',
      'unconscious_choking/foreign_object/adult',       'unconscious_choking/foreign_object/infant',
      'unconscious_choking/liquid/adult',               'unconscious_choking/liquid/infant',
      'unconscious_choking/other_circumstances/adult',  'unconscious_choking/other_circumstances/infant',
    ],

  };

  // ── Public accessors ──

  /// All keys that must be completed before the quiz unlocks for [lessonId].
  static List<String> forLesson(int lessonId) =>
      _requirements[lessonId] ?? [];

  /// Total number of lessons required for [lessonId].
  static int totalFor(int lessonId) => forLesson(lessonId).length;

  // ── Normalise any string to snake_case ──

  static String _normalise(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');

  // ── Key builder ──

  // Burns / Choking (subcategory + type/degree + age group):
  //   LessonRequirements.buildKey(
  //     subcategory: _selectedSubcategory,  // e.g. 'mild_choking'
  //     degree:      _selectedBurnDegree,    // e.g. 'food'
  //     ageGroup:    _selectedOption,         // 'adult' | 'infant'
  //   );
  //   → 'mild_choking/food/adult'
  //
  // Lessons with subcategory but no type/degree:
  //   LessonRequirements.buildKey(subcategory: 'cpr', ageGroup: 'adult');
  //   → 'cpr/adult'
  //
  // Lessons with neither:
  //   LessonRequirements.buildKey(ageGroup: 'adult');
  //   → 'adult'

  static String buildKey({
    String? subcategory,
    String? degree,
    required String ageGroup,
  }) {
    final hasSub    = subcategory != null && subcategory.isNotEmpty;
    final hasDegree = degree != null && degree.isNotEmpty;

    final sub  = hasSub    ? _normalise(subcategory!) : null;
    final deg  = hasDegree ? _normalise(degree!)      : null;
    final age  = _normalise(ageGroup);

    if (sub != null && deg != null) return '$sub/$deg/$age';
    if (sub != null)                return '$sub/$age';
    return age;
  }
}