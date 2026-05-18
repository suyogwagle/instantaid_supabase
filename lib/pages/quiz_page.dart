
// Entry point for the quiz feature. Checks lesson completion before allowing
// access — shows QuizGateScreen if not all lessons are complete.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/quiz_controller.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import '../services/progress_service.dart';
import '../widget/lesson_requirements.dart';
import 'quiz_question_screen.dart';
import 'quiz_result_screen.dart';
import 'quiz_gate_screen.dart';

class QuizPage extends StatefulWidget {
  final int lessonId;
  final String lessonTitle;
  final QuizDifficulty? difficulty;
  final int questionCount;

  const QuizPage({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    this.difficulty,
    this.questionCount = 10,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  QuizController? _controller;

  bool _checkingEligibility = true;
  QuizEligibility? _eligibility;

  @override
  void initState() {
    super.initState();
    // Defer provider reads to the first frame — context.read() inside
    // initState() runs before the widget is fully inserted into the tree,
    // which causes ProviderNotFoundException even when providers are registered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = context.read<QuizService>();
      _controller = QuizController(service);
      // Notify listeners so Consumer<QuizController> picks up the controller
      if (mounted) setState(() {});
      _checkEligibilityThenLoad();
    });
  }

  // ── check completion before touching the quiz ──

  Future<void> _checkEligibilityThenLoad() async {
    if (!mounted) return;
    setState(() => _checkingEligibility = true);

    final progressService = context.read<ProgressService>();
    final required = LessonRequirements.forLesson(widget.lessonId);

    final eligibility = await progressService.checkQuizEligibility(
      lessonId:              widget.lessonId,
      requiredSubcategories: required,
    );

    setState(() {
      _eligibility = eligibility;
      _checkingEligibility = false;
    });

    if (eligibility.isEligible) _startQuiz();
  }

  // ── load questions (only reached when eligible) ──

  void _startQuiz() {
    _controller?.startQuiz(
      lessonId:      widget.lessonId,
      difficulty:    widget.difficulty,
      questionCount: widget.questionCount,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _controller is null on the very first build (assigned in postFrameCallback).
    // Show a loading scaffold until it is ready.
    if (_controller == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider.value(
      value: _controller!,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.black87),
        onPressed: () => _eligibility?.isEligible == true
            ? _showExitDialog(context)
            : Navigator.pop(context),
      ),
      title: Text(
        widget.lessonTitle,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
      centerTitle: true,
      actions: [
        Consumer<QuizController>(
          builder: (_, ctrl, __) {
            if (ctrl.phase != QuizPhase.active) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${ctrl.liveScore}/${ctrl.totalQuestions}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue.shade700),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    // Eligibility check in progress
    if (_checkingEligibility) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Checking your progress…', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Not eligible — show gate screen with what's missing
    if (_eligibility != null && !_eligibility!.isEligible) {
      return QuizGateScreen(
        eligibility:  _eligibility!,
        lessonTitle:  widget.lessonTitle,
        onGoToLesson: () => Navigator.pop(context),
      );
    }

    // Eligible — normal quiz flow
    return Consumer<QuizController>(
      builder: (context, ctrl, _) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildQuizBody(ctrl),
      ),
    );
  }

  Widget _buildQuizBody(QuizController ctrl) {
    switch (ctrl.phase) {
      case QuizPhase.loading:
        return const _LoadingView(key: ValueKey('loading'));
      case QuizPhase.error:
        return _ErrorView(
          key: const ValueKey('error'),
          message: ctrl.errorMessage ?? 'Something went wrong.',
          onRetry: _startQuiz,
        );
      case QuizPhase.active:
        return const QuizQuestionScreen(key: ValueKey('question'));
      case QuizPhase.complete:
        return QuizResultScreen(
          key:      const ValueKey('result'),
          onRetry:  _startQuiz,
          onReview: (ctrl.result != null && ctrl.result!.wrongAnswers.isNotEmpty)
              ? () => ctrl.showReview()
              : null,          onExit:   () => Navigator.pop(context),
        );
      case QuizPhase.reviewing:
        return QuizReviewScreen(
          key:     const ValueKey('review'),
          results: ctrl.result!.wrongAnswers,
          onDone:  () => Navigator.pop(context),
        );
      case QuizPhase.idle:
        return const SizedBox.shrink();
    }
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Quit quiz?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: const Text('Your progress will be lost if you exit now.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep going')),
          TextButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            child: Text('Exit', style: TextStyle(color: Colors.red.shade600)),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Text('Loading questions…', style: TextStyle(color: Colors.grey)),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          const Text('Failed to load quiz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Retry')),
        ],
      ),
    ),
  );
}