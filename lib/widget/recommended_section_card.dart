import 'package:flutter/material.dart';

// Design tokens (mirrors app theme)
class _C {
  static const teal      = Color(0xFF00897B);
  static const tealFaint = Color(0xFFE0F2F1);
  static const tealLight = Color(0xFFB2DFDB);
  static const textPri   = Color(0xFF0A1628);
  static const textSec   = Color(0xFF64748B);
  static const divider   = Color(0xFFECEFF4);
  static const blue      = Color(0xFF1565C0);
  static const surface   = Colors.white;

  static List<BoxShadow> shadow = [
    const BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
}

class RecommendedSectionCard extends StatelessWidget {
  final int categoryId;
  final String categoryName;
  final String imageUrl;
  final int chaptersRemaining;
  final double progress;        // 0.0 – 1.0; defaults to 0 if not supplied
  final String? emoji;
  final VoidCallback? onTap;

  const RecommendedSectionCard({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrl,
    required this.chaptersRemaining,
    this.progress = 0.0,
    this.emoji,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct    = (progress * 100).round();
    final isDone = pct == 100;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _C.shadow,
        ),
        child: Row(
          children: [
            // ── Thumbnail ────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              child: SizedBox(
                width: 90,
                height: 90,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: _C.tealFaint,
                    child: Center(
                      child: Text(
                        emoji ?? '📖',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Info ─────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _C.textPri,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$chaptersRemaining ${chaptersRemaining == 1 ? 'lesson' : 'lessons'}',
                      style: const TextStyle(fontSize: 12, color: _C.textSec),
                    ),
                    const SizedBox(height: 10),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: _C.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDone ? _C.teal : _C.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDone ? 'Complete ✓' : '$pct% complete',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDone ? _C.teal : _C.textSec,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Arrow ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _C.tealFaint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: _C.teal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}