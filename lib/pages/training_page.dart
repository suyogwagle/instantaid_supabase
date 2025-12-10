// training_page.dart
import 'package:flutter/material.dart';
import 'package:instant_aid/pages/lesson_page.dart';
import 'package:instant_aid/pages/training_list_page.dart';
import '../widget/lesson_card.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  String? _selectedLesson;

  final List<String> _selectedOptions = [
    "Burn Treatment",
    "Choking Response",
    "Fracture Treatment",
    "Minor injuries",
    "Frost Bite Treatment",
    "CPR Procedure",
  ];

  @override
  void initState() {
    super.initState();
    _selectedLesson = _selectedOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: _buildAppBar(),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildTopImage(screenHeight),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: _buildMainContent(screenWidth, screenHeight),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.0),
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: _circleButton(
          icon: Icons.arrow_back_ios_new_sharp,
          onTap: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: _circleButton(
            icon: Icons.bookmark_border,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  //TOP IMAGE SECTION
  Widget _buildTopImage(double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.30,
      width: double.infinity,
      child: Stack(
        children: [
          Image.network(
            'https://thumbs.dreamstime.com/b/idyllic-summer-landscape-clear-mountain-lake-alps-45054687.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => Center(
              child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.transparent, Colors.black12],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //MAIN CONTENT
  Widget _buildMainContent(double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(screenWidth),
          const SizedBox(height: 10),

          _buildDescriptionText(screenWidth),
          SizedBox(height: screenHeight * 0.01),

          _buildReadMore(screenWidth),
          SizedBox(height: screenHeight * 0.03),

          _buildRelatedLessonsHeader(screenWidth),
          SizedBox(height: screenHeight * 0.015),

          _buildLessonScroll(screenHeight),
          SizedBox(height: screenHeight * 0.02),

          _buildVisualContentHeader(screenWidth),
          _buildVisualContent(screenHeight),
        ],
      ),
    );
  }

  //SMALL UI BUILDERS
  Widget _buildHeaderRow(double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDropdownBox(width),
        _buildChapterCountBox(width),
      ],
    );
  }

  Widget _buildDropdownBox(double width) {
    return Container(
      width: width * 0.55,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLesson,
          isExpanded: true,
          elevation: 16,
          onChanged: (val) => setState(() => _selectedLesson = val),
          items: _selectedOptions.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChapterCountBox(double width) {
    return Container(
      width: width * 0.28,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Text(
        "7 chapters",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDescriptionText(double width) {
    return Text(
      "A comprehensive guide to Basic Life Support procedures including CPR, choking response, "
          "and basic wound care. This course equips individuals with essential skills to respond to emergencies.",
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: width * 0.038),
    );
  }

  Widget _buildReadMore(double width) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LessonPage()),
      ),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
        ),
        child: Text(
          "Read More",
          style: TextStyle(
            fontSize: width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedLessonsHeader(double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Related Lessons",
          style: TextStyle(fontSize: width * 0.055, fontWeight: FontWeight.bold),
        ),
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TrainingListPage()),
          ),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
            ),
            child: Text(
              "See all",
              style: TextStyle(
                fontSize: width * 0.038,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonScroll(double height) {
    return SizedBox(
      height: height * 0.28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (_, __) => LessonCard(),
      ),
    );
  }

  Widget _buildVisualContentHeader(double width) {
    return Text(
      "Visual Content",
      style: TextStyle(
        fontSize: width * 0.055,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildVisualContent(double height) {
    return Container(
      width: double.infinity,
      height: height * 0.25,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Image.network(
        'https://thumbs.dreamstime.com/b/idyllic-summer-landscape-clear-mountain-lake-alps-45054687.jpg',
        fit: BoxFit.cover,
      ),
    );
  }

  //REUSABLE CIRCLE BUTTON
  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white.withValues(alpha: 0.5),
        child: Icon(icon, size: 24, color: Colors.black),
      ),
    );
  }
}
