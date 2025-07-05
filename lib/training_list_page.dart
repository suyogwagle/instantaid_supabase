import 'package:flutter/material.dart';
import 'package:instant_aid/widget//lesson_card.dart';

class TrainingListPage extends StatelessWidget {
  const TrainingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Training List Page"), centerTitle: true),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          child: Column(
            children: <Widget>[LessonCard(), LessonCard(), LessonCard(), LessonCard(), LessonCard(), LessonCard(), LessonCard()],
          ),
        ),
      ),
    );
  }
}
