// Reusable components used across quiz screens. Each widget is self-contained
// and takes only what it needs — no controller dependency here.

import 'package:flutter/material.dart';
import '../models/quiz.dart';

// ── Option tile ──

enum OptionState { idle, selected, correct, wrong }

class QuizOptionTile extends StatelessWidget {
  final String label;
  final String text;
  final OptionState state;
  final VoidCallback? onTap;

  const QuizOptionTile({
    super.key,
    required this.label,
    required this.text,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color borderColor;
    Color bgColor;
    Color labelBg;
    Color labelFg;
    Color textColor;

    switch (state) {
      case OptionState.correct:
        borderColor = Colors.green.shade400;
        bgColor     = Colors.green.shade50;
        labelBg     = Colors.green.shade400;
        labelFg     = Colors.white;
        textColor   = Colors.green.shade900;
      case OptionState.wrong:
        borderColor = Colors.red.shade300;
        bgColor     = Colors.red.shade50;
        labelBg     = Colors.red.shade400;
        labelFg     = Colors.white;
        textColor   = Colors.red.shade900;
      case OptionState.selected:
        borderColor = theme.colorScheme.primary;
        bgColor     = theme.colorScheme.primary.withValues(alpha: 0.08);
        labelBg     = theme.colorScheme.primary;
        labelFg     = Colors.white;
        textColor   = theme.colorScheme.primary;
      case OptionState.idle:
        borderColor = Colors.grey.shade300;
        bgColor     = Colors.white;
        labelBg     = Colors.grey.shade100;
        labelFg     = Colors.grey.shade700;
        textColor   = Colors.black87;
    }

    return GestureDetector(
      onTap: state == OptionState.idle ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            // Letter badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: labelBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: labelFg,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Option text
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                  height: 1.4,
                ),
              ),
            ),
            // State icon
            if (state == OptionState.correct)
              Icon(Icons.check_circle_rounded, color: Colors.green.shade500, size: 20),
            if (state == OptionState.wrong)
              Icon(Icons.cancel_rounded, color: Colors.red.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Quiz progress bar ──

class QuizProgressBar extends StatelessWidget {
  final double value;        // 0.0 – 1.0
  final int current;
  final int total;

  const QuizProgressBar({
    super.key,
    required this.value,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question $current of $total',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

// ── Feedback explanation box ──

class QuizFeedbackBox extends StatelessWidget {
  final bool isCorrect;
  final String explanation;

  const QuizFeedbackBox({
    super.key,
    required this.isCorrect,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? Colors.green : Colors.red;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect ? Icons.check_circle_outline : Icons.info_outline,
            color: color.shade600,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'Correct!' : 'Not quite',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  explanation,
                  style: TextStyle(
                    fontSize: 13,
                    color: color.shade900,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category badge ──

class CategoryBadge extends StatelessWidget {
  final String label;
  final QuizDifficulty difficulty;

  const CategoryBadge({
    super.key,
    required this.label,
    required this.difficulty,
  });

  Color _difficultyColor() {
    switch (difficulty) {
      case QuizDifficulty.beginner:     return Colors.green;
      case QuizDifficulty.intermediate: return Colors.orange;
      case QuizDifficulty.advanced:     return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _difficultyColor();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Color(8), // needs change
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            difficulty.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(50) //needs change
            ),
          ),
        ),
      ],
    );
  }
}

// ── Animated score ring ──

class ScoreRing extends StatefulWidget {
  final int percentage;   // 0–100
  final double size;

  const ScoreRing({super.key, required this.percentage, this.size = 120});

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = Tween<double>(begin: 0, end: widget.percentage / 100)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color _ringColor(int pct) {
    if (pct >= 80) return Colors.green.shade400;
    if (pct >= 50) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: _anim.value,
                  color: _ringColor(widget.percentage),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(widget.percentage * _anim.value).round()}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'score',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width - 12) / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Track
    canvas.drawArc(
      rect, 0, 2 * 3.14159, false,
      Paint()
        ..color = Colors.grey.shade200
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Fill
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -3.14159 / 2,
        2 * 3.14159 * progress,
        false,
        Paint()
          ..color = color
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Stat card (used on result screen) ──

class QuizStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const QuizStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}