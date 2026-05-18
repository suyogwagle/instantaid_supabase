// Shown instead of the quiz when the user hasn't completed all required
// lessons. Displays a clear progress breakdown and links back to the lesson.

import 'package:flutter/material.dart';
import '../services/progress_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens (mirrors app theme)
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  static const navy      = Color(0xFF0A1628);
  static const teal      = Color(0xFF00897B);
  static const tealLight = Color(0xFFB2DFDB);
  static const tealFaint = Color(0xFFE0F2F1);
  static const tealDark  = Color(0xFF00695C);
  static const bg        = Color(0xFFF4F6F9);
  static const surface   = Colors.white;
  static const textPri   = Color(0xFF0A1628);
  static const textSec   = Color(0xFF64748B);
  static const divider   = Color(0xFFECEFF4);
  static const red       = Color(0xFFD32F2F);
  static const redFaint  = Color(0xFFFFEBEE);
  static const redLight  = Color(0xFFFFCDD2);
  static const amber     = Color(0xFFF57C00);
  static const amberFaint= Color(0xFFFFF3E0);
  static const green     = Color(0xFF2E7D32);
  static const greenFaint= Color(0xFFE8F5E9);
  static const blue      = Color(0xFF1565C0);
  static const blueFaint = Color(0xFFE3F2FD);

  static List<BoxShadow> shadow = [
    const BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static List<BoxShadow> shadowSm = [
    const BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
  ];
}

class QuizGateScreen extends StatelessWidget {
  final QuizEligibility eligibility;
  final String lessonTitle;
  final VoidCallback onGoToLesson;

  const QuizGateScreen({
    super.key,
    required this.eligibility,
    required this.lessonTitle,
    required this.onGoToLesson,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.bg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // ── Lock badge ─────────────────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _C.navy,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _C.navy.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.lock_outline_rounded, size: 34, color: Colors.white),
              ),
              const SizedBox(height: 20),

              // ── Title ──────────────────────────────────────────────────
              const Text(
                'Quiz Locked',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _C.textPri,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete all $lessonTitle lessons\nbefore taking the quiz.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: _C.textSec,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 32),

              // ── Progress summary ───────────────────────────────────────
              _ProgressSummary(eligibility: eligibility),
              const SizedBox(height: 16),

              // ── Missing lessons ────────────────────────────────────────
              if (eligibility.missingSubcategories.isNotEmpty) ...[
                _MissingList(missing: eligibility.missingSubcategories),
                const SizedBox(height: 32),
              ] else
                const SizedBox(height: 16),

              // ── CTA ────────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onGoToLesson,
                  icon: const Icon(Icons.menu_book_rounded, size: 20),
                  label: const Text(
                    'Continue Lesson',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress summary card
// ─────────────────────────────────────────────────────────────────────────────
class _ProgressSummary extends StatelessWidget {
  final QuizEligibility eligibility;
  const _ProgressSummary({required this.eligibility});

  @override
  Widget build(BuildContext context) {
    final pct    = eligibility.progressPercent;
    final isDone = pct == 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider),
        boxShadow: _C.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isDone ? _C.greenFaint : _C.tealFaint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDone ? Icons.verified_rounded : Icons.auto_stories_rounded,
                  color: isDone ? _C.green : _C.teal,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Overall Progress',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _C.textPri)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDone ? _C.greenFaint : _C.tealFaint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDone ? _C.green : _C.teal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: eligibility.progressFraction,
              minHeight: 8,
              backgroundColor: _C.divider,
              valueColor: AlwaysStoppedAnimation<Color>(isDone ? _C.green : _C.teal),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${eligibility.completedCount} of ${eligibility.totalRequired} sections complete',
            style: const TextStyle(fontSize: 12, color: _C.textSec),
          ),
          const SizedBox(height: 16),

          // Stat pills
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Completed',
                  value: '${eligibility.completedCount}',
                  color: _C.green,
                  faint: _C.greenFaint,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPill(
                  icon: Icons.radio_button_unchecked_rounded,
                  label: 'Remaining',
                  value: '${eligibility.totalRequired - eligibility.completedCount}',
                  color: _C.amber,
                  faint: _C.amberFaint,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPill(
                  icon: Icons.list_alt_rounded,
                  label: 'Total',
                  value: '${eligibility.totalRequired}',
                  color: _C.blue,
                  faint: _C.blueFaint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color faint;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.faint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: faint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: _C.textSec)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Missing lessons list
// ─────────────────────────────────────────────────────────────────────────────
class _MissingList extends StatefulWidget {
  final List<String> missing;
  const _MissingList({required this.missing});

  @override
  State<_MissingList> createState() => _MissingListState();
}

class _MissingListState extends State<_MissingList> {
  bool _expanded = false;
  static const _previewCount = 4;

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAll('/', ' — ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final showCount = _expanded
        ? widget.missing.length
        : _previewCount.clamp(0, widget.missing.length);
    final hasMore = widget.missing.length > _previewCount;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.redLight),
        boxShadow: _C.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _C.redFaint,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: _C.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.assignment_late_outlined, color: _C.red, size: 17),
                ),
                const SizedBox(width: 10),
                Text(
                  '${widget.missing.length} lesson${widget.missing.length == 1 ? '' : 's'} remaining',
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: _C.red,
                  ),
                ),
              ],
            ),
          ),

          // List items
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...widget.missing.take(showCount).map((key) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          color: _C.redFaint,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.close_rounded, size: 14, color: _C.red),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            _formatKey(key),
                            style: const TextStyle(
                              fontSize: 13, color: _C.textPri, height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

                if (hasMore) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _C.tealFaint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _expanded
                            ? 'Show less'
                            : '+ ${widget.missing.length - _previewCount} more',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _C.teal,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}