// Displays one question at a time with options, feedback, and a next button.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/quiz_controller.dart';
import '../widget/quiz_widgets.dart';

class QuizQuestionScreen extends StatelessWidget {
  const QuizQuestionScreen({super.key});

  static const _labels = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<QuizController>();
    final q = ctrl.currentQuestion;
    if (q == null) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress
            QuizProgressBar(
              value:   ctrl.progress,
              current: ctrl.currentIndex + 1,
              total:   ctrl.totalQuestions,
            ),
            const SizedBox(height: 20),

            // Category + difficulty badges
            CategoryBadge(label: q.category, difficulty: q.difficulty),
            const SizedBox(height: 20),

            // Question text
            Text(
              q.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),

            // Options
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...q.options.asMap().entries.map((entry) {
                      final i     = entry.key;
                      final text  = entry.value;
                      final state = _optionState(ctrl, i);

                      return QuizOptionTile(
                        label:  _labels[i],
                        text:   text,
                        state:  state,
                        onTap:  ctrl.isAnswered ? null : () => ctrl.selectAnswer(i),
                      );
                    }),

                    // Feedback box
                    if (ctrl.isAnswered) ...[
                      QuizFeedbackBox(
                        isCorrect:   ctrl.selectedIndex == q.correctIndex,
                        explanation: q.explanation,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // Next / Finish button
            AnimatedSlide(
              offset: ctrl.isAnswered ? Offset.zero : const Offset(0, 0.3),
              duration: const Duration(milliseconds: 250),
              child: AnimatedOpacity(
                opacity:  ctrl.isAnswered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: ctrl.isAnswered ? ctrl.nextQuestion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        ctrl.isLastQuestion ? 'See results' : 'Next question',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OptionState _optionState(QuizController ctrl, int index) {
    if (!ctrl.isAnswered) return OptionState.idle;
    final q = ctrl.currentQuestion!;
    if (index == q.correctIndex)              return OptionState.correct;
    if (index == ctrl.selectedIndex)          return OptionState.wrong;
    return OptionState.idle;
  }
}