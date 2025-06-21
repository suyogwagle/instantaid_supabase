import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

/// Model class for a training progress item
class TrainingProgress {
  final double progress; // Value between 0.0 and 1.0
  final String title;

  TrainingProgress(this.progress, this.title);
}

/// Reusable widget that cycles through training progress cards
class SlidingTrainingProgress extends StatefulWidget {
  final List<TrainingProgress> progressItems;
  final Duration slideDuration;
  final Duration displayDuration;

  const SlidingTrainingProgress({
    super.key,
    required this.progressItems,
    this.slideDuration = const Duration(milliseconds: 700),
    this.displayDuration = const Duration(seconds: 3),
  });

  @override
  State<SlidingTrainingProgress> createState() =>
      _SlidingTrainingProgressState();
}

class _SlidingTrainingProgressState extends State<SlidingTrainingProgress> {
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      widget.displayDuration + widget.slideDuration,
      (timer) {
        setState(() {
          _currentIndex =
              (_currentIndex + 1) % widget.progressItems.length;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget _buildProgressCard(TrainingProgress item) {
    return AnimatedTrainingProgress(
      targetProgress: item.progress,
      title: item.title,
      key: ValueKey(item.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ClipRect(
        child: AnimatedSwitcher(
          duration: widget.slideDuration,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (child, animation) {
            final isIncoming =
                child.key == ValueKey(widget.progressItems[_currentIndex].title);

            final slideIn = Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

            final fadeOut = Tween<double>(
              begin: 1.0,
              end: 0.0,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));

            return isIncoming
                ? SlideTransition(position: slideIn, child: child)
                : FadeTransition(opacity: fadeOut, child: child);
          },
          child: _buildProgressCard(widget.progressItems[_currentIndex]),
        ),
      ),
    );
  }
}

/// A single animated training card with circular progress
class AnimatedTrainingProgress extends StatelessWidget {
  final double targetProgress; // Value between 0.0 and 1.0
  final String title;

  const AnimatedTrainingProgress({
    super.key,
    required this.targetProgress,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: targetProgress),
      duration: const Duration(seconds: 2),
      builder: (context, value, _) {
        return Card(
          margin: const EdgeInsets.only(top: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 50.0,
                  lineWidth: 8.0,
                  percent: value.clamp(0.0, 1.0),
                  animation: false,
                  center: Text(
                    "${(value * 100).toInt()}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.blueAccent,
                  backgroundColor: Colors.grey[300]!,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
