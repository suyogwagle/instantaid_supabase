import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({super.key});

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
                      height: 120.0,
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
                      // Add navigation or action logic here
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

class LessonCards extends StatelessWidget {
  const LessonCards({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180.0,
      width: 400.0,
      child: Card(
        color: Colors.grey[100],
        margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
          child: Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  'https://thumbs.dreamstime.com/b/idyllic-summer-landscape-clear-mountain-lake-alps-45054687.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),

              Positioned(
                bottom:20.0,
                left: 5.0,
                child: GestureDetector(
                  onTap: () {
                    // Add navigation logic here
                  },
                  child: CircleAvatar(
                    radius: 20.0,
                    backgroundColor: Colors.white.withValues(alpha: 0.5, red: 0.95, blue: 0.95, green: 0.95),
                    child: const Icon(
                      Icons.bookmark_border,
                      size: 25.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 28.0,
                right: 5.0,
                child: Container(
                  width: 120.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    shape: BoxShape.rectangle,
                    // color: Colors.grey[300],
                  ),
                  child: Text(
                    "Lesson Title",
                    //need to be changed when data is available
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              Positioned(
                bottom: 5.0,
                right: 5.0,
                child: Container(
                  width: 100.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    shape: BoxShape.rectangle,
                    // color: Colors.grey[300],
                  ),
                  child: Text(
                    "9 chapters",
                    //need to be changed when data is available
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
