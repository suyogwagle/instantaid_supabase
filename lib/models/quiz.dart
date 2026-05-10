// All data structures for the quiz system.
class QuizQuestion {
  final int id;
  final String category;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final QuizDifficulty difficulty;

  const QuizQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.difficulty = QuizDifficulty.beginner,
  });

  // Deserialize from a Supabase / API JSON map.
  // Expected keys: id, category, question, options (List), correct_index,
  //                explanation, difficulty (string)
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id:           json['id'] as int,
      category:     json['category'] as String,
      question:     json['question'] as String,
      // options is jsonb in Supabase — comes back as List<dynamic>
      options:      List<String>.from(json['options'] as List),
      correctIndex: json['correct_index'] as int,
      // explanation and difficulty are optional — default gracefully if absent
      explanation:  json['explanation'] as String? ?? '',
      difficulty:   QuizDifficulty.fromString(json['difficulty'] as String? ?? 'beginner'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':            id,
    'category':      category,
    'question':      question,
    'options':       options,
    'correct_index': correctIndex,
    'explanation':   explanation,
    'difficulty':    difficulty.name,
  };
}

// ── Difficulty ──
enum QuizDifficulty {
  beginner,
  intermediate,
  advanced;

  static QuizDifficulty fromString(String value) {
    return QuizDifficulty.values.firstWhere(
          (d) => d.name == value.toLowerCase(),
      orElse: () => QuizDifficulty.beginner,
    );
  }

  String get label {
    switch (this) {
      case QuizDifficulty.beginner:     return 'Beginner';
      case QuizDifficulty.intermediate: return 'Intermediate';
      case QuizDifficulty.advanced:     return 'Advanced';
    }
  }
}

// ── Per-question result ──

class QuestionResult {
  final QuizQuestion question;
  final int selectedIndex;
  final bool isCorrect;
  final Duration timeTaken;

  const QuestionResult({
    required this.question,
    required this.selectedIndex,
    required this.isCorrect,
    required this.timeTaken,
  });
}

// ── Full quiz session result ──

class QuizResult {
  final List<QuestionResult> questionResults;
  final DateTime completedAt;

  const QuizResult({
    required this.questionResults,
    required this.completedAt,
  });

  int get totalQuestions  => questionResults.length;
  int get correctCount    => questionResults.where((r) => r.isCorrect).length;
  int get incorrectCount  => totalQuestions - correctCount;
  int get scorePercentage => totalQuestions == 0 ? 0 : (correctCount / totalQuestions * 100).round();

  String get grade {
    final pct = scorePercentage;
    if (pct >= 90) return 'A';
    if (pct >= 80) return 'B';
    if (pct >= 70) return 'C';
    if (pct >= 60) return 'D';
    return 'F';
  }

  int get bestStreak {
    int best = 0, current = 0;
    for (final r in questionResults) {
      if (r.isCorrect) { current++; if (current > best) best = current; }
      else current = 0;
    }
    return best;
  }

  Duration get totalTime => questionResults.fold(
    Duration.zero, (sum, r) => sum + r.timeTaken,
  );

  // Questions the user answered incorrectly, useful for review screen.
  List<QuestionResult> get wrongAnswers =>
      questionResults.where((r) => !r.isCorrect).toList();
}