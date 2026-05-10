import 'package:flutter/material.dart';
import 'package:instant_aid/pages/lesson_page.dart';
import 'package:instant_aid/pages/quiz_page.dart';
import 'package:instant_aid/pages/training_list_page.dart';
import '../widget/lesson_card.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  String _selectedLesson = "Burn Treatment";
  bool _isBookmarked = false;
  bool _isDescriptionExpanded = false;

  final List<Map<String, dynamic>> _lessons = [
    {
      'id': 1,
      'name': 'Burn Treatment',
      'chapters': 7,
      'difficulty': 'Beginner',
      'duration': '25 min',
      'icon': '🔥',
      'color': Colors.orange,
      'imageUrl': 'https://www.cederroth.com/app/uploads/2020/10/ill_burn_gel_spray_new_spray2-1024x626.jpg',
    },
    {
      'id': 2,
      'name': 'Choking Response',
      'chapters': 5,
      'difficulty': 'Intermediate',
      'duration': '15 min',
      'icon': '🫁',
      'color': Colors.red,
      'imageUrl': 'https://www.cederroth.com/app/uploads/2020/10/ill_burn_gel_spray_new_spray2-1024x626.jpg',
    },
    {
      'id': 3,
      'name': 'Fracture Treatment',
      'chapters': 8,
      'difficulty': 'Advanced',
      'duration': '30 min',
      'icon': '🦴',
      'color': Colors.blue,
      'imageUrl': 'https://www.cederroth.com/app/uploads/2020/10/ill_burn_gel_spray_new_spray2-1024x626.jpg',
    },
    {
      'id': 4,
      'name': 'Minor Injuries',
      'chapters': 6,
      'difficulty': 'Beginner',
      'duration': '20 min',
      'icon': '🩹',
      'color': Colors.green,
      'imageUrl': 'https://www.cederroth.com/app/uploads/2020/10/ill_burn_gel_spray_new_spray2-1024x626.jpg',
    },
    {
      'id': 5,
      'name': 'CPR Procedure',
      'chapters': 9,
      'difficulty': 'Advanced',
      'duration': '35 min',
      'icon': '❤️',
      'color': Colors.red,
      'imageUrl': 'https://www.cederroth.com/app/uploads/2020/10/ill_burn_gel_spray_new_spray2-1024x626.jpg',
    },
  ];

  // Related lessons map to main lesson ids so navigation is consistent
  final List<Map<String, dynamic>> _relatedLessons = [
    {
      'id': 1,
      'title': 'Heatstroke Management',
      'duration': '12 min',
      'difficulty': 'Beginner',
      'progress': 0.6,
      'thumbnail': '☀️',
      'color': Colors.orange[100],
      'imageUrl': 'https://www.cederroth.com/app/uploads/2020/10/ill_burn_gel_spray_new_spray2-1024x626.jpg',
    },
    {
      'id': 2,
      'title': 'Chemical Burns',
      'duration': '18 min',
      'difficulty': 'Intermediate',
      'progress': 0.0,
      'thumbnail': '⚗️',
      'color': Colors.purple[100],
      'imageUrl': 'https://www.cederroth.com/app/uploads/2020/10/ill_burn_gel_spray_new_spray2-1024x626.jpg',
    },
    {
      'id': 3,
      'title': 'Electrical Burns',
      'duration': '15 min',
      'difficulty': 'Advanced',
      'progress': 0.3,
      'thumbnail': '⚡',
      'color': Colors.yellow[100],
      'imageUrl': 'https://www.cederroth.com/app/uploads/2020/10/ill_burn_gel_spray_new_spray2-1024x626.jpg',
    },
    {
      'id': 4,
      'title': 'Sunburn Care',
      'duration': '10 min',
      'difficulty': 'Beginner',
      'progress': 1.0,
      'thumbnail': '🌞',
      'color': Colors.amber[100],
      'imageUrl': 'https://www.cederroth.com/app/uploads/2020/10/ill_burn_gel_spray_new_spray2-1024x626.jpg',
    },
  ];

  // Helper: look up the currently selected lesson map
  Map<String, dynamic> get _currentLesson => _lessons.firstWhere(
        (l) => l['name'] == _selectedLesson,
    orElse: () => _lessons.first,
  );

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final currentLesson = _currentLesson;

    return Scaffold(
      appBar: _buildAppBar(),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildTopImage(screenHeight, currentLesson),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildMainContent(screenWidth, screenHeight, currentLesson),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(currentLesson),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: _circleButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: _circleButton(
            icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            onTap: () {
              setState(() => _isBookmarked = !_isBookmarked);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isBookmarked ? 'Course bookmarked' : 'Bookmark removed'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopImage(double screenHeight, Map<String, dynamic> currentLesson) {
    return SizedBox(
      height: screenHeight * 0.32,
      width: double.infinity,
      child: Stack(
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1584820927498-cfe5211fd8bf?w=800',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => Container(
              color: (currentLesson['color'] as Color).withValues(alpha: 0.3),
              child: Center(
                child: Icon(Icons.medical_services, size: 80, color: Colors.grey[400]),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: currentLesson['color'] as Color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(currentLesson['icon'], style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        currentLesson['difficulty'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'First Aid Training',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedLesson,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
      double screenWidth,
      double screenHeight,
      Map<String, dynamic> currentLesson,
      ) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsRow(currentLesson),
            const SizedBox(height: 24),
            _buildCourseSelector(screenWidth),
            const SizedBox(height: 24),
            _buildDescriptionSection(),
            const SizedBox(height: 32),
            _buildCourseHighlights(),
            const SizedBox(height: 32),
            _buildRelatedLessonsSection(screenHeight),
            const SizedBox(height: 32),
            _buildVisualContentSection(screenHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> currentLesson) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.menu_book,
            label: 'Chapters',
            value: '${currentLesson['chapters']}',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time,
            label: 'Duration',
            value: currentLesson['duration'],
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star,
            label: 'Rating',
            value: '4.8',
            color: Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildCourseSelector(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Course',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLesson,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 28),
              // Selecting a course updates the displayed lesson AND resets to
              // that lesson's data — no hardcoded ids anywhere.
              onChanged: (val) => setState(() => _selectedLesson = val!),
              items: _lessons.map((lesson) {
                return DropdownMenuItem<String>(
                  value: lesson['name'] as String,
                  child: Row(
                    children: [
                      Text(lesson['icon'], style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          lesson['name'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    const description =
        "A comprehensive guide to Basic Life Support procedures including CPR, "
        "choking response, and basic wound care. This course equips individuals with essential "
        "skills to respond to emergencies effectively and confidently. Learn life-saving techniques "
        "that can make a critical difference in emergency situations.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Overview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          maxLines: _isDescriptionExpanded ? null : 4,
          overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
          child: Row(
            children: [
              Text(
                _isDescriptionExpanded ? 'Show Less' : 'Read More',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              Icon(
                _isDescriptionExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.blue,
                size: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseHighlights() {
    final highlights = [
      {'icon': Icons.verified, 'text': 'Certified by Medical Professionals'},
      {'icon': Icons.update, 'text': 'Updated with Latest Guidelines'},
      {'icon': Icons.phone_in_talk, 'text': '24/7 Support Available'},
      {'icon': Icons.workspace_premium, 'text': 'Certificate Upon Completion'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Highlights',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
        ),
        const SizedBox(height: 16),
        ...highlights.map((highlight) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(highlight['icon'] as IconData, color: Colors.green[700], size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    highlight['text'] as String,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.4),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRelatedLessonsSection(double screenHeight) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Related Lessons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrainingListPage()),
              ),
              child: const Row(
                children: [
                  Text(
                    'See All',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 12, color: Colors.blue),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _relatedLessons.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) => _buildRelatedLessonCard(_relatedLessons[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedLessonCard(Map<String, dynamic> lesson) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LessonPage(
            // ← FIXED: was hardcoded id: 1 with no imageUrl
            id:       lesson['id']       as int,
            imageUrl: lesson['imageUrl'] as String,
          ),
        ),
      ),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: lesson['color'] as Color?,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(lesson['thumbnail'], style: const TextStyle(fontSize: 48)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson['title'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        lesson['duration'],
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if ((lesson['progress'] as double) > 0) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: lesson['progress'] as double,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          lesson['progress'] == 1.0 ? Colors.green : Colors.blue,
                        ),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson['progress'] == 1.0
                          ? 'Completed'
                          : '${((lesson['progress'] as double) * 100).round()}% done',
                      style: TextStyle(
                        fontSize: 10,
                        color: lesson['progress'] == 1.0 ? Colors.green : Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualContentSection(double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visual Guide',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1551601651-2a8555f1a136?w=800',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(Icons.play_circle_outline, size: 60, color: Colors.grey[400]),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, size: 40, color: Colors.blue),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '12:45',
                      style: TextStyle(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(Map<String, dynamic> currentLesson) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizPage(
                  lessonId:    currentLesson['id'] as int,
                  lessonTitle: currentLesson['name'] as String,
                  questionCount: 5,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: currentLesson['color'] as Color,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_filled, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Start Course',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}