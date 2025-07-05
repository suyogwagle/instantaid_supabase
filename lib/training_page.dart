// training_page.dart
import 'package:flutter/material.dart';
import 'package:instant_aid/lesson_page.dart';
import 'package:instant_aid/training_list_page.dart';
import 'widget/lesson_card.dart'; // Assuming lesson_card.dart is defined

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  // --- State variables for the dropdown ---
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
    _selectedLesson = _selectedOptions[0];
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    // final double statusBarHeight = MediaQuery.of(context).padding.top;
    // kToolbarHeight is usually 56.0 for a standard AppBar
    // final double appBarHeight = kToolbarHeight;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.0),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CircleAvatar(
              radius: 20.0,
              backgroundColor: Colors.white.withValues(
                alpha: 0.5,
                red: 0.95,
                blue: 0.95,
                green: 0.95,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_sharp,
                size: 25.0,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () {
                // Add action for bookmark
              },
              child: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.white.withValues(
                  alpha: 0.5,
                  red: 0.95,
                  blue: 0.95,
                  green: 0.95,
                ),
                child: const Icon(
                  Icons.bookmark_border,
                  size: 25.0,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),

      // Keeps the body content (image) extending behind the AppBar
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey[100],

      body: Column(
        children: <Widget>[
          SizedBox(
            height: screenHeight * 0.3,
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                Image.network(
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
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 0.0),
                    padding: const EdgeInsets.all(10.0),
                    width: double.infinity,
                    height: screenHeight *1.0 ,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Positioned(
                              top: 5.0,
                              left: 5.0,
                              child: Container(
                                width: screenHeight * 0.25,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  shape: BoxShape.rectangle,
                                  // color: Colors.grey[400],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedLesson,
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.black,
                                    ),
                                    iconSize: 28,
                                    elevation: 16,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                    ),
                                    isExpanded: true,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedLesson = newValue;
                                      });
                                    },
                                    items: _selectedOptions
                                        .map<DropdownMenuItem<String>>((
                                        String value,
                                        ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    })
                                        .toList(),

                                    selectedItemBuilder:
                                        (BuildContext context) {
                                      return _selectedOptions.map<Widget>((
                                          String item,
                                          ) {
                                        return Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              top: 5.0,
                              right: 5.0,
                              child: Container(
                                width: screenHeight * 0.13,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  shape: BoxShape.rectangle,
                                  // color: Colors.grey[500],
                                ),
                                child: Center(
                                  child: Text(
                                    "7 chapters",
                                    //need to be changed when data is available
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Text(
                          "A comprehensive guide to Basic Life Support procedures including CPR, choking response, and basic wound care. This course is designed to equip individuals with essential skills to respond to medical emergencies effectively. It covers theoretical knowledge and practical applications, adhering to international guidelines. Learn life-saving techniques that can make a difference in critical situations. Ideal for first responders, healthcare professionals, and anyone interested in emergency preparedness.",
                          style: TextStyle(
                            fontSize: screenWidth * 0.038,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenHeight * 0.01),

                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LessonPage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Text(
                              "Read More",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Related Lessons",
                              style: TextStyle(
                                fontSize: screenWidth * 0.055,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const TrainingListPage(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                padding: const EdgeInsets.only(bottom: 0.2),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "See all",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.038,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        SizedBox(
                          height: screenHeight * 0.3,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 0.0,
                            ),

                            child: Row(
                              children: <Widget>[
                                LessonCard(),
                                const SizedBox(width: 15.0),
                                LessonCard(),
                                const SizedBox(width: 15.0),
                                LessonCard(),
                                const SizedBox(width: 15.0),
                                LessonCard(),
                                const SizedBox(width: 15.0),
                                LessonCard(),
                                const SizedBox(width: 15.0),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        Text(
                          'Visual Content here',
                          style: TextStyle(
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: screenHeight * 0.25,
                          color: Colors.grey[100],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                width: double.infinity,
                                child: Image.network('https://thumbs.dreamstime.com/b/idyllic-summer-landscape-clear-mountain-lake-alps-45054687.jpg')),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
