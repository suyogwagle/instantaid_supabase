// Shown instead of the quiz when the user hasn't completed all required
// lessons. Displays a clear progress breakdown and links back to the lesson.

import 'package:flutter/material.dart';
import '../services/progress_service.dart';

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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // Lock icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange.shade200, width: 2),
              ),
              child: Icon(Icons.lock_outline_rounded, size: 34, color: Colors.orange.shade600),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Quiz locked',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete all $lessonTitle lessons before taking the quiz.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 32),

            // Progress ring + counts
            _ProgressSummary(eligibility: eligibility),
            const SizedBox(height: 32),

            // Missing lessons list
            if (eligibility.missingSubcategories.isNotEmpty) ...[
              _MissingList(missing: eligibility.missingSubcategories),
              const SizedBox(height: 32),
            ],

            // CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onGoToLesson,
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Continue lesson'),
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
          ],
        ),
      ),
    );
  }
}

// ── Progress summary card ──

class _ProgressSummary extends StatelessWidget {
  final QuizEligibility eligibility;

  const _ProgressSummary({required this.eligibility});

  @override
  Widget build(BuildContext context) {
    final pct = eligibility.progressPercent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall progress',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: pct == 100 ? Colors.green : Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: eligibility.progressFraction,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                pct == 100 ? Colors.green : Colors.orange.shade500,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Completed / total pills
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Completed',
                  value: '${eligibility.completedCount}',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatPill(
                  icon: Icons.radio_button_unchecked_rounded,
                  label: 'Remaining',
                  value: '${eligibility.totalRequired - eligibility.completedCount}',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatPill(
                  icon: Icons.list_alt_rounded,
                  label: 'Total',
                  value: '${eligibility.totalRequired}',
                  color: Colors.blue,
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

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ── Missing lessons list ──

class _MissingList extends StatefulWidget {
  final List<String> missing;
  const _MissingList({required this.missing});

  @override
  State<_MissingList> createState() => _MissingListState();
}

class _MissingListState extends State<_MissingList> {
  bool _expanded = false;

  // Show first 4 by default; expand to show all
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
    final showCount = _expanded ? widget.missing.length : _previewCount.clamp(0, widget.missing.length);
    final hasMore   = widget.missing.length > _previewCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_late_outlined, color: Colors.red.shade600, size: 18),
              const SizedBox(width: 8),
              Text(
                '${widget.missing.length} lessons remaining',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.missing.take(showCount).map((key) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.circle, size: 6, color: Colors.red.shade400),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _formatKey(key),
                    style: TextStyle(fontSize: 13, color: Colors.red.shade900, height: 1.4),
                  ),
                ),
              ],
            ),
          )),
          if (hasMore) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded
                    ? 'Show less'
                    : '+ ${widget.missing.length - _previewCount} more',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}