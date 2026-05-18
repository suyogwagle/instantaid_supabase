import 'package:flutter/material.dart';
import 'package:instant_aid/pages/homepage.dart';
import 'package:instant_aid/pages/lesson_page.dart';
import 'package:instant_aid/widget/recommended_section_card.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../widget/lesson_requirements.dart';


class _C {
  // Brand
  static const navy      = Color(0xFF0A1628);
  static const teal      = Color(0xFF00897B);
  static const tealLight = Color(0xFFB2DFDB);
  static const tealFaint = Color(0xFFE0F2F1);
  static const tealDark  = Color(0xFF00695C);

  // Greys
  static const bg        = Color(0xFFF4F6F9);
  static const surface   = Colors.white;
  static const textPri   = Color(0xFF0A1628);
  static const textSec   = Color(0xFF64748B);
  static const divider   = Color(0xFFECEFF4);

  // Semantic
  // static const red       = Color(0xFFD32F2F);
  // static const redFaint  = Color(0xFFFFEBEE);
  // static const amber     = Color(0xFFF57C00);
  // static const amberFaint= Color(0xFFFFF3E0);

  static List<BoxShadow> shadow = [
    const BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static List<BoxShadow> shadowSm = [
    const BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
  ];
}

class TrainingListPage extends StatefulWidget {
  const TrainingListPage({super.key});

  @override
  State<TrainingListPage> createState() => _TrainingListPageState();
}

class _TrainingListPageState extends State<TrainingListPage> {
  final Map<int, double> _progressMap = {};
  bool _progressLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final service = context.read<ProgressService>();
    final updated = <int, double>{};
    for (final lesson in kLessons) {
      final id = lesson['id'] as int;
      final required = LessonRequirements.forLesson(id);
      if (required.isEmpty) { updated[id] = 0.0; continue; }
      final eligibility = await service.checkQuizEligibility(
        lessonId: id,
        requiredSubcategories: required,
      );
      updated[id] = eligibility.progressFraction;
    }
    if (mounted) {
      setState(() {
        _progressMap.addAll(updated);
        _progressLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Training"), centerTitle: true),
      body: _progressLoaded
          ? ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kLessons.length,
        itemBuilder: (context, index) {
          final lesson = kLessons[index];
          return RecommendedSectionCard(
            categoryId: lesson['id'] as int,
            categoryName: lesson['name'] as String,
            imageUrl: lesson['imageUrl'] as String,
            chaptersRemaining: lesson['chapters'] as int,
            emoji: lesson['emoji'] as String?,
            progress: _progressMap[lesson['id'] as int] ?? 0.0,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonPage(
                    id: lesson['id'] as int,
                    imageUrl: lesson['imageUrl'] as String,
                  ),
                ),
              );
              // Refresh progress when returning from a lesson
              _loadProgress();
            },
          );
        },
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _C.shadowSm,
      ),
      child: TextField(
        style: const TextStyle(fontSize: 14, color: _C.textPri),
        decoration: InputDecoration(
          hintText: 'Search lessons, topics…',
          hintStyle: const TextStyle(color: _C.textSec, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: _C.textSec, size: 20),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _C.teal, width: 1.5)),
          filled: true,
          fillColor: _C.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}