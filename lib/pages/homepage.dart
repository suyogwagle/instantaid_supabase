import 'package:flutter/material.dart';
import 'package:instant_aid/pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:instant_aid/main.dart';
import 'package:instant_aid/emergency_page.dart';
import 'package:instant_aid/pages/lesson_page.dart';
import 'package:instant_aid/pages/notifications_page.dart';
import 'package:instant_aid/pages/userpage.dart';
import 'package:instant_aid/services/hybrid_intent_classifier.dart';
import 'package:instant_aid/services/injury_classifier.dart';
import 'package:instant_aid/services/whisper_service.dart';
// import 'package:instant_aid/pages/training_page.dart';
import 'package:instant_aid/widget/recommended_section_card.dart';
import '../models/user_model.dart';
import '../services/progress_service.dart';
import '../widget/lesson_requirements.dart';
import '../widget/state_transition.dart';

class HomePage extends StatefulWidget {
  final UserModel user;
  final HybridIntentClassifier hybridClassifier;
  const HomePage({super.key, required this.user, required this.hybridClassifier});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  final InjuryClassifier classifier = InjuryClassifier();
  final WhisperService whisper = WhisperService();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserPage(user: widget.user)),
      );
    } else if (index == 2) {
      Future.microtask(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmergencyModeScreen(
              classifier: classifier,
              whisper: whisper,
              hybridClassifier: widget.hybridClassifier,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeContent(user: widget.user),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: BottomNavigationBar(
            elevation: 10.0,
            backgroundColor: Colors.black,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedIconTheme: const IconThemeData(color: Colors.white, size: 32),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.warning_rounded), label: ''),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final UserModel user;
  const HomeContent({super.key, required this.user});

  // ── Lesson data ───────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> _lessons = [
    {
      'id': 1,
      'name': 'Burn Treatment',
      'chapters': 40,
      'imageUrl': 'https://www.cederroth.com/app/uploads/2020/10/ill_burn_gel_spray_new_spray2-1024x626.jpg',
    },
    {
      'id': 2,
      'name': 'Choking Response',
      'chapters': 24,
      'imageUrl': 'https://i.ytimg.com/vi/ItOpBTwVaKs/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLA7qAgUiCZsDCX2lTUaAbUOtTStig',
    },
    {
      'id': 3,
      'name': 'CPR Procedure',
      'chapters': 7,
      'imageUrl': 'https://www.shutterstock.com/image-vector/safety-officer-demonstrating-cpr-technique-600nw-2604186017.jpg',
    },
    {
      'id': 4,
      'name': 'Fracture Treatment',
      'chapters': 7,
      'imageUrl': 'https://cdn.vectorstock.com/i/1000v/65/84/cartoon-flat-style-drawing-leg-fracture-patient-vector-48356584.jpg',
    },
    {
      'id': 5,
      'name': 'Minor Injuries',
      'chapters': 7,
      'imageUrl': 'https://thumbs.dreamstime.com/b/little-boy-elbow-ache-scooter-accident-sad-unhappy-little-boy-suffering-elbow-ache-sitting-grass-scooter-188127730.jpg',
    },
  ];
  // ─────────────────────────────────────────────────────────────────────────

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // lessonId → progress fraction (0.0 – 1.0)
  final Map<int, double> _progressMap = {};
  bool _progressLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  // Called again when user returns from LessonPage so progress refreshes
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_progressLoaded) _loadProgress();
  }

  Future<void> _loadProgress() async {
    final service = context.read<ProgressService>();
    final updated = <int, double>{};

    for (final lesson in HomeContent._lessons) {
      final id       = lesson['id'] as int;
      final required = LessonRequirements.forLesson(id);
      if (required.isEmpty) {
        updated[id] = 0.0;
        continue;
      }
      final eligibility = await service.checkQuizEligibility(
        lessonId:              id,
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${widget.user.fullName ?? widget.user.username ?? 'User'}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Text('Welcome to InstantAId'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_active_sharp, color: Colors.black54),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsPage()),
                      );
                    },
                  ),
                ),
                PopupMenuButton<int>(
                  onSelected: (value) async {
                    if (value == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserPage(user: widget.user)),
                      );
                    } else if (value == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      );
                    } else if (value == 2) {
                      try {
                        await supabase.auth.signOut();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Logout failed: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 0, child: Text("Profile")),
                    const PopupMenuItem(value: 1, child: Text("Settings")),
                    const PopupMenuItem(value: 2, child: Text("Logout")),
                  ],
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: (widget.user.avatarUrl != null && widget.user.avatarUrl!.isNotEmpty)
                        ? NetworkImage(widget.user.avatarUrl!)
                        : const NetworkImage(
                        "https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcQIy4d7P3mJN5n44jxkUjp24w5W1FF2ro43MBxyZqTV2EOB9hVgw1ZW3m9kFoxqA6TD2AqigsYj")
                    as ImageProvider,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: const Color(0xFF006DBF).withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  "Current Progress",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // Padding(
                //   padding: const EdgeInsets.only(right: 10.0),
                //   child: InkWell(
                //     onTap: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(builder: (context) => LessonPage(id: id, imageUrl: imageUrl),
                //       );
                //     },
                //     child: Container(
                //       padding: const EdgeInsets.only(bottom: 0.25),
                //       decoration: const BoxDecoration(
                //         border: Border(
                //           bottom: BorderSide(color: Colors.black, width: 1.5),
                //         ),
                //       ),
                //       child: const Text("Keep Learning", style: TextStyle(fontSize: 16)),
                //     ),
                //   ),
                // ),
              ],
            ),
            if (!_progressLoaded)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(),
              )
            else
              SlidingTrainingProgress(
                progressItems: HomeContent._lessons
                    .where((l) => LessonRequirements.forLesson(l['id'] as int).isNotEmpty)
                    .map((l) => TrainingProgress(
                  _progressMap[l['id'] as int] ?? 0.0,
                  l['name'] as String,
                ))
                    .toList(),
              ),
            const SizedBox(height: 10),
            const Text(
              "Recommended Lessons",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Dynamic lesson cards driven by _lessons list above.
            // Each card passes its own imageUrl into LessonPage so the
            // header image matches the selected category.
            ...HomeContent._lessons.map((lesson) => RecommendedSectionCard(
              categoryId:        lesson['id']       as int,
              categoryName:      lesson['name']     as String,
              imageUrl:          lesson['imageUrl'] as String,
              chaptersRemaining: lesson['chapters'] as int,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonPage(
                      id:       lesson['id']       as int,
                      imageUrl: lesson['imageUrl'] as String,
                    ),
                  ),
                );
                // Refresh progress when user returns from lesson
                _loadProgress();
              },
            )),
          ],
        ),
      ),
    );
  }
}