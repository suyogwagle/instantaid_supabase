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
import 'package:instant_aid/widget/recommended_section_card.dart';
import 'package:instant_aid/pages/training_list_page.dart';
import '../models/user_model.dart';
import '../services/progress_service.dart';
import '../widget/lesson_requirements.dart';
import '../widget/state_transition.dart';

// Design tokens
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
  static const red       = Color(0xFFD32F2F);
  static const redFaint  = Color(0xFFFFEBEE);
  static const amber     = Color(0xFFF57C00);
  static const amberFaint= Color(0xFFFFF3E0);

  static List<BoxShadow> shadow = [
    const BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static List<BoxShadow> shadowSm = [
    const BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
  ];
}

// Lesson catalogue — single source of truth
const List<Map<String, dynamic>> kLessons = [
  {
    'id': 1,
    'name': 'Burn Treatment',
    'chapters': 40,
    'emoji': '🔥',
    'imageUrl':
    'https://www.cederroth.com/app/uploads/2020/10/ill_burn_gel_spray_new_spray2-1024x626.jpg',
  },
  {
    'id': 2,
    'name': 'Choking Response',
    'chapters': 24,
    'emoji': '🫁',
    'imageUrl':
    'https://i.ytimg.com/vi/ItOpBTwVaKs/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLA7qAgUiCZsDCX2lTUaAbUOtTStig',
  },
  {
    'id': 3,
    'name': 'CPR Procedure',
    'chapters': 7,
    'emoji': '❤️',
    'imageUrl':
    'https://www.shutterstock.com/image-vector/safety-officer-demonstrating-cpr-technique-600nw-2604186017.jpg',
  },
  {
    'id': 4,
    'name': 'Fracture Treatment',
    'chapters': 7,
    'emoji': '🦴',
    'imageUrl':
    'https://cdn.vectorstock.com/i/1000v/65/84/cartoon-flat-style-drawing-leg-fracture-patient-vector-48356584.jpg',
  },
  {
    'id': 5,
    'name': 'Minor Injuries',
    'chapters': 7,
    'emoji': '🩹',
    'imageUrl':
    'https://thumbs.dreamstime.com/b/little-boy-elbow-ache-scooter-accident-sad-unhappy-little-boy-suffering-elbow-ache-sitting-grass-scooter-188127730.jpg',
  },
];

// ─────────────────────────────────────────────────────────────────────────────
// HomePage — shell with bottom nav
// ─────────────────────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  final UserModel user;
  final HybridIntentClassifier hybridClassifier;
  const HomePage({super.key, required this.user, required this.hybridClassifier});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  final InjuryClassifier _classifier = InjuryClassifier();
  final WhisperService _whisper = WhisperService();

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => UserPage(user: widget.user)),
      ).then((_) { if (mounted) setState(() => _selectedIndex = 1); });
    } else if (index == 2) {
      Future.microtask(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmergencyModeScreen(
              classifier: _classifier,
              whisper: _whisper,
              hybridClassifier: widget.hybridClassifier,
            ),
          ),
        ).then((_) { if (mounted) setState(() => _selectedIndex = 1); });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: _HomeBody(user: widget.user),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign out', style: TextStyle(fontWeight: FontWeight.w700, color: _C.textPri)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(color: _C.textSec)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _C.textSec)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await supabase.auth.signOut();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Logout failed: $e'),
                    backgroundColor: _C.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
                }
              }
            },
            child: const Text('Sign out', style: TextStyle(color: _C.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom nav — floating pill design
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;
  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: _C.navy,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                const BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, 8)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,
                    label: 'Profile', index: 0, selectedIndex: selectedIndex, onTap: onTap),
                _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded,
                    label: 'Home', index: 1, selectedIndex: selectedIndex, onTap: onTap),
                _SosNavItem(index: 2, selectedIndex: selectedIndex, onTap: onTap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int selectedIndex;
  final void Function(int) onTap;
  const _NavItem({required this.icon, required this.activeIcon, required this.label,
    required this.index, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _C.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon,
                color: isSelected ? Colors.white : Colors.grey.shade500, size: 22),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SosNavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final void Function(int) onTap;
  const _SosNavItem({required this.index, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _C.red : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sos_rounded,
                color: isSelected ? Colors.white : Colors.grey.shade500, size: 22),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Text('SOS',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HomeBody — scrollable content
// ─────────────────────────────────────────────────────────────────────────────
class _HomeBody extends StatefulWidget {
  final UserModel user;
  const _HomeBody({required this.user});

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final Map<int, double> _progressMap = {};
  bool _progressLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_progressLoaded) _loadProgress();
  }

  Future<void> _loadProgress() async {
    final service = context.read<ProgressService>();
    final updated = <int, double>{};
    for (final lesson in kLessons) {
      final id = lesson['id'] as int;
      final required = LessonRequirements.forLesson(id);
      if (required.isEmpty) { updated[id] = 0.0; continue; }
      final eligibility = await service.checkQuizEligibility(
          lessonId: id, requiredSubcategories: required);
      updated[id] = eligibility.progressFraction;
    }
    if (mounted) setState(() { _progressMap.addAll(updated); _progressLoaded = true; });
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.user.fullName ?? widget.user.username ?? 'User';
    final firstName = displayName.split(' ').first;

    return CustomScrollView(
      slivers: [
        // ── Hero header ───────────────────────────────────────────────────
        SliverToBoxAdapter(child: _HeroHeader(user: widget.user, firstName: firstName)),

        // ── Body content ─────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),
              _SearchBar(),
              const SizedBox(height: 24),

              // Progress section
              _SectionHeader(title: 'Current Progress'),
              const SizedBox(height: 12),
              if (!_progressLoaded)
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _C.shadowSm,
                  ),
                  child: const Center(child: LinearProgressIndicator(color: _C.teal)),
                )
              else
                SlidingTrainingProgress(
                  progressItems: kLessons
                      .where((l) => LessonRequirements.forLesson(l['id'] as int).isNotEmpty)
                      .map((l) => TrainingProgress(
                    _progressMap[l['id'] as int] ?? 0.0,
                    l['name'] as String,
                  ))
                      .toList(),
                ),

              const SizedBox(height: 28),
              _SectionHeader(
                title: _progressLoaded && _progressMap.values.any((p) => p > 0)
                    ? 'Continue Learning'
                    : 'Start Learning',
                onSeeAll: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TrainingListPage()),
                ),
              ),
              const SizedBox(height: 12),
              if (!_progressLoaded)
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _C.shadowSm,
                  ),
                  child: const Center(child: LinearProgressIndicator(color: _C.teal)),
                )
              else if (_progressMap.values.any((p) => p > 0))
                ..._lessonCards()
              else
                _EmptyState(),
            ]),
          ),
        ),
      ],
    );
  }

  List<Widget> _lessonCards() {
    return kLessons
        .where((lesson) => (_progressMap[lesson['id'] as int] ?? 0.0) > 0)
        .map((lesson) {
      final progress = _progressMap[lesson['id'] as int] ?? 0.0;
      return RecommendedSectionCard(
        categoryId: lesson['id'] as int,
        categoryName: lesson['name'] as String,
        imageUrl: lesson['imageUrl'] as String,
        chaptersRemaining: lesson['chapters'] as int,
        emoji: lesson['emoji'] as String?,
        progress: progress,
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
          _loadProgress();
        },
      );
    }).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero header with gradient and greeting
// ─────────────────────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final UserModel user;
  final String firstName;
  const _HeroHeader({required this.user, required this.firstName});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A1628), Color(0xFF0D3B5E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row — greeting + actions
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(greeting,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(firstName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5)),
                      ],
                    ),
                  ),
                  // Notification bell
                  _HeaderAction(
                    icon: Icons.notifications_outlined,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const NotificationsPage())),
                  ),
                  const SizedBox(width: 8),
                  // Avatar menu
                  _AvatarMenu(user: user),
                ],
              ),
              const SizedBox(height: 20),

              // Quick-stat chips
              Row(
                children: [
                  _StatChip(icon: Icons.book_outlined, label: '${kLessons.length} Lessons'),
                  const SizedBox(width: 10),
                  _StatChip(icon: Icons.emoji_events_outlined, label: 'Learn & Stay Safe'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _C.tealLight, size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state — shown when no lessons have been started
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _C.shadowSm,
      ),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: _C.tealFaint, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.menu_book_rounded, color: _C.teal, size: 28),
          ),
          const SizedBox(height: 14),
          const Text('No lessons started yet',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _C.textPri)),
          const SizedBox(height: 6),
          const Text(
            'Tap "See all" to browse all lessons\nand start learning.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _C.textSec, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header with optional "See all"
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: _C.textPri, letterSpacing: -0.3)),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text('See all lessons',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _C.teal)),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search bar
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// Avatar menu (unchanged logic, refreshed visuals)
// ─────────────────────────────────────────────────────────────────────────────
class _AvatarMenu extends StatelessWidget {
  final UserModel user;
  const _AvatarMenu({required this.user});

  String get _initial {
    final name = user.fullName ?? user.username ?? user.email ?? '';
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;

    return PopupMenuButton<_MenuAction>(
      onSelected: (action) => _handleAction(context, action),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      itemBuilder: (_) => const [
        PopupMenuItem(value: _MenuAction.profile,
            child: _MenuRow(icon: Icons.person_outline_rounded, label: 'Profile')),
        PopupMenuItem(value: _MenuAction.settings,
            child: _MenuRow(icon: Icons.settings_outlined, label: 'Settings')),
        PopupMenuItem(value: _MenuAction.logout,
            child: _MenuRow(icon: Icons.logout_rounded, label: 'Logout', isDestructive: true)),
      ],
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
        ),
        child: CircleAvatar(
          radius: 20,
          backgroundImage: hasPhoto ? NetworkImage(user.avatarUrl!) : null,
          backgroundColor: hasPhoto ? null : _C.teal,
          child: hasPhoto ? null : Text(_initial,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, _MenuAction action) async {
    switch (action) {
      case _MenuAction.profile:
        Navigator.push(context, MaterialPageRoute(builder: (_) => UserPage(user: user)));
      case _MenuAction.settings:
        Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage(user: user)));
      case _MenuAction.logout:
        try {
          await supabase.auth.signOut();
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Logout failed: $e'), backgroundColor: _C.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            );
          }
        }
    }
  }
}

enum _MenuAction { profile, settings, logout }

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  const _MenuRow({required this.icon, required this.label, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? _C.red : _C.textPri;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
      ],
    );
  }
}