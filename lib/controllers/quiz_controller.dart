// ─────────────────────────────────────────────────────────────────────────────
// quiz_controller.dart
// ChangeNotifier that drives every quiz screen. No business logic lives in
// the UI — screens only read state and call methods on this controller.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';


enum QuizPhase { idle, loading, active, reviewing, complete, error }

class QuizController extends ChangeNotifier {
  final QuizService _service;

  QuizController(this._service);

  // ── Readable state ─────────────────────────────────────────────────────────

  QuizPhase phase = QuizPhase.idle;
  String? errorMessage;

  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedIndex;       // null = unanswered
  bool _isAnswered = false;
  DateTime? _questionStartTime;

  final List<QuestionResult> _results = [];

  // ── Derived getters ────────────────────────────────────────────────────────

  QuizQuestion? get currentQuestion =>
      _questions.isEmpty ? null : _questions[_currentIndex];

  int get currentIndex    => _currentIndex;
  int get totalQuestions  => _questions.length;
  int? get selectedIndex  => _selectedIndex;
  bool get isAnswered     => _isAnswered;
  bool get isLastQuestion => _currentIndex == _questions.length - 1;

  double get progress =>
      _questions.isEmpty ? 0 : (_currentIndex) / _questions.length;

  QuizResult? get result => phase == QuizPhase.complete
      ? QuizResult(questionResults: List.unmodifiable(_results), completedAt: DateTime.now())
      : null;

  // Current running score (shown during the quiz)
  int get liveScore => _results.where((r) => r.isCorrect).length;

  // ── Public methods ─────────────────────────────────────────────────────────

  /// Load questions and start a fresh quiz session.
  Future<void> startQuiz({
    required int lessonId,
    QuizDifficulty? difficulty,
    int questionCount = 5,
  }) async {
    phase = QuizPhase.loading;
    errorMessage = null;
    notifyListeners();

    try {
      _questions = await _service.getQuestions(
        lessonId:   lessonId,
        difficulty: difficulty,
        limit:       questionCount,
      );

      if (_questions.isEmpty) {
        phase = QuizPhase.error;
        errorMessage = 'No questions found for this lesson.';
        notifyListeners();
        return;
      }

      _reset();
      phase = QuizPhase.active;
      _questionStartTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      phase = QuizPhase.error;
      errorMessage = 'Failed to load quiz: $e';
      notifyListeners();
    }
  }

  /// Record the user's answer for the current question.
  void selectAnswer(int index) {
    if (_isAnswered) return;

    _selectedIndex = index;
    _isAnswered = true;

    final q = currentQuestion!;
    final elapsed = DateTime.now().difference(_questionStartTime!);

    _results.add(QuestionResult(
      question:      q,
      selectedIndex: index,
      isCorrect:     index == q.correctIndex,
      timeTaken:     elapsed,
    ));

    notifyListeners();
  }

  /// Advance to the next question, or finish the quiz.
  void nextQuestion() {
    if (!_isAnswered) return;

    if (isLastQuestion) {
      phase = QuizPhase.complete;
      notifyListeners();
      return;
    }

    _currentIndex++;
    _selectedIndex = null;
    _isAnswered = false;
    _questionStartTime = DateTime.now();
    notifyListeners();
  }

  /// Show the per-question review (wrong answers only) after completion.
  void showReview() {
    phase = QuizPhase.reviewing;
    notifyListeners();
  }

  /// Reset everything so the widget tree can call startQuiz() again.
  void reset() {
    _reset();
    phase = QuizPhase.idle;
    notifyListeners();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _reset() {
    _currentIndex = 0;
    _selectedIndex = null;
    _isAnswered = false;
    _results.clear();
  }
}