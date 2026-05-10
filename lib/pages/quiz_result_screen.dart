// quiz_result_screen.dart
// Shown after the last question. Displays score ring, stats, and action buttons.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/quiz_controller.dart';
import '../widget/quiz_widgets.dart';

class QuizResultScreen extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback? onReview;
  final VoidCallback onExit;

  const QuizResultScreen({
    super.key,
    required this.onRetry,
    required this.onExit,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final result = context.read<QuizController>().result!;
    final pct    = result.scorePercentage;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Header
            _buildHeader(pct),
            const SizedBox(height: 28),

            // Score ring
            ScoreRing(percentage: pct),
            const SizedBox(height: 32),

            // Stats grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                QuizStatCard(
                  value: '${result.correctCount}',
                  label: 'Correct',
                  icon: Icons.check_circle_outline_rounded,
                  color: Colors.green,
                ),
                QuizStatCard(
                  value: '${result.incorrectCount}',
                  label: 'Incorrect',
                  icon: Icons.cancel_outlined,
                  color: Colors.red,
                ),
                QuizStatCard(
                  value: '${result.bestStreak}',
                  label: 'Best streak',
                  icon: Icons.local_fire_department_outlined,
                  color: Colors.orange,
                ),
                QuizStatCard(
                  value: result.grade,
                  label: 'Grade',
                  icon: Icons.school_outlined,
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Motivational message
            _buildMotivationalText(pct),
            const SizedBox(height: 32),

            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Try again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            if (onReview != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onReview,
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Review wrong answers'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onExit,
                child: const Text('Back to lesson'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int pct) {
    final isGood = pct >= 70;
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: (isGood ? Colors.green : Colors.orange).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isGood ? Icons.emoji_events_rounded : Icons.trending_up_rounded,
            size: 30,
            color: isGood ? Colors.green.shade600 : Colors.orange.shade600,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          isGood ? 'Great work!' : 'Keep practicing!',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Quiz complete',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildMotivationalText(int pct) {
    final String msg;
    if (pct == 100) {
      msg = 'Perfect score! You have mastered this topic.';
    } else if (pct >= 80) {
      msg = 'Excellent! You have a strong grasp of this material.';
    } else if (pct >= 60) {
      msg = 'Good effort. Review the explanations to strengthen weak areas.';
    } else {
      msg = 'Keep studying — re-read the lesson and try again.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.blue.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade900,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Lists every question the user got wrong with the correct answer highlighted.

class QuizReviewScreen extends StatelessWidget {
  final List<dynamic> results;  // List<QuestionResult>
  final VoidCallback onDone;

  const QuizReviewScreen({
    super.key,
    required this.results,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                const Text(
                  'Wrong answers',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${results.length} to review',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) => _ReviewCard(result: results[i]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final dynamic result; // QuestionResult

  const _ReviewCard({required this.result});

  static const _labels = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final q          = result.question;
    final correct    = q.correctIndex as int;
    final selected   = result.selectedIndex as int;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Text(
            q.question as String,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),

          // Your answer (wrong)
          _answerRow(
            label:    _labels[selected],
            text:     (q.options as List)[selected] as String,
            isWrong:  true,
          ),
          const SizedBox(height: 6),

          // Correct answer
          _answerRow(
            label:     _labels[correct],
            text:      (q.options as List)[correct] as String,
            isCorrect: true,
          ),
          const SizedBox(height: 12),

          // Explanation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    q.explanation as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _answerRow({
    required String label,
    required String text,
    bool isCorrect = false,
    bool isWrong   = false,
  }) {
    final color  = isCorrect ? Colors.green : (isWrong ? Colors.red : Colors.grey);
    final prefix = isCorrect ? 'Correct: ' : (isWrong ? 'Your answer: ' : '');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.shade100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color.shade700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
              children: [
                TextSpan(
                  text: prefix,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color.shade700,
                  ),
                ),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
        Icon(
          isCorrect ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: color.shade400,
        ),
      ],
    );
  }
}