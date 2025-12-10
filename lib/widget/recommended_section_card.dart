import 'package:flutter/material.dart';
import 'package:instant_aid/pages/lesson_page.dart';

class RecommendedSectionCard extends StatefulWidget {
  const RecommendedSectionCard({super.key});

  @override
  State<RecommendedSectionCard> createState() => _RecommendedSectionCardState();
}

class _RecommendedSectionCardState extends State<RecommendedSectionCard> {
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320.0,
      width: 260.0,
      margin: const EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 10.0),
      child: Card(
        elevation: 8.0,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.blue.shade50,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Image Container with Gradient Overlay
                Stack(
                  children: <Widget>[
                    Hero(
                      tag: 'burn_treatment',
                      child: Container(
                        height: 160.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/firstaid_burns.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.blue.shade100,
                                    child: const Center(
                                      child: Icon(
                                        Icons.local_hospital_rounded,
                                        size: 60,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Gradient overlay for better text readability
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.3),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Bookmark Button
                    Positioned(
                      top: 8.0,
                      right: 8.0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isBookmarked = !isBookmarked;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            size: 22.0,
                            color: isBookmarked ? Colors.red.shade400 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12.0),

                // Title
                const Text(
                  'Burn Treatment',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6.0),

                // Progress Info
                Row(
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      size: 16.0,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      "7 chapters remaining",
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12.0),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Progress Indicator
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.trending_up,
                              size: 16.0,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 6.0),
                            Text(
                              "Start Learning",
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12.0),

                    // Continue Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 22.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}