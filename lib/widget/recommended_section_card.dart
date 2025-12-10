import 'package:flutter/material.dart';
import 'package:instant_aid/pages/lesson_page.dart';

class RecommendedSectionCard extends StatelessWidget {
  const RecommendedSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300.0,
      width: 260.0,
      child: Card(
        color: Colors.grey[100],
        margin: EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 10.0),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.all(7.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      'https://thumbs.dreamstime.com/b/idyllic-summer-landscape-clear-mountain-lake-alps-45054687.jpg',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 150.0,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120.0,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 80,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Positioned(
                  //   top: 8.0,
                  //   left: 8.0,
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       // Add navigation or action logic here
                  //     },
                  //     child: CircleAvatar(
                  //       radius: 20.0,
                  //       backgroundColor: Colors.grey[300],
                  //       child: const Icon(
                  //         Icons.bookmark_border,
                  //         size: 25.0,
                  //         color: Colors.black,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),

              const SizedBox(height: 4.0),

              const Text(
                'Lesson Title', //change this
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 1.0),

              const Text(
                "9 chapters", // Change this
                style: TextStyle(fontSize: 12.0, color: Colors.black),
              ),
              const SizedBox(height: 4.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Add navigation or action logic here
                    },
                    child: CircleAvatar(
                      radius: 20.0,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(
                        Icons.bookmark_border,
                        size: 25.0,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LessonPage(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20.0,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(
                        Icons.arrow_forward,
                        size: 25.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
