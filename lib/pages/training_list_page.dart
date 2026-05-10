import 'package:flutter/material.dart';
import 'package:instant_aid/widget/recommended_section_card.dart';

class TrainingListPage extends StatelessWidget {
  const TrainingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Training List Page"), centerTitle: true),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            RecommendedSectionCard(
              categoryId: 1,
              categoryName: 'Burn Treatment',
              imageUrl: 'https://thumbs.dreamstime.com/b/idyllic-summer-landscape-clear-mountain-lake-alps-45054687.jpg',
              chaptersRemaining: 7,
            ),
            RecommendedSectionCard(
              categoryId: 1,
              categoryName: 'Burn Treatment',
              imageUrl: 'https://thumbs.dreamstime.com/b/idyllic-summer-landscape-clear-mountain-lake-alps-45054687.jpg',
              chaptersRemaining: 7,
            ),
            RecommendedSectionCard(
              categoryId: 1,
              categoryName: 'Burn Treatment',
              imageUrl: 'https://thumbs.dreamstime.com/b/idyllic-summer-landscape-clear-mountain-lake-alps-45054687.jpg',
              chaptersRemaining: 7,
            ),
            RecommendedSectionCard(
              categoryId: 1,
              categoryName: 'Burn Treatment',
              imageUrl: 'https://thumbs.dreamstime.com/b/idyllic-summer-landscape-clear-mountain-lake-alps-45054687.jpg',
              chaptersRemaining: 7,
            ),
            RecommendedSectionCard(
              categoryId: 1,
              categoryName: 'Burn Treatment',
              imageUrl: 'https://thumbs.dreamstime.com/b/idyllic-summer-landscape-clear-mountain-lake-alps-45054687.jpg',
              chaptersRemaining: 7,
            ),
            RecommendedSectionCard(
              categoryId: 1,
              categoryName: 'Burn Treatment',
              imageUrl: 'https://thumbs.dreamstime.com/b/idyllic-summer-landscape-clear-mountain-lake-alps-45054687.jpg',
              chaptersRemaining: 7,
            ),
            RecommendedSectionCard(
              categoryId: 1,
              categoryName: 'Burn Treatment',
              imageUrl: 'https://thumbs.dreamstime.com/b/idyllic-summer-landscape-clear-mountain-lake-alps-45054687.jpg',
              chaptersRemaining: 7,
            ),
            RecommendedSectionCard(
              categoryId: 1,
              categoryName: 'Burn Treatment',
              imageUrl: 'https://thumbs.dreamstime.com/b/idyllic-summer-landscape-clear-mountain-lake-alps-45054687.jpg',
              chaptersRemaining: 7,
            ),
            RecommendedSectionCard(
              categoryId: 1,
              categoryName: 'Burn Treatment',
              imageUrl: 'https://thumbs.dreamstime.com/b/idyllic-summer-landscape-clear-mountain-lake-alps-45054687.jpg',
              chaptersRemaining: 7,
            ),
            ],
        ),
      ),
    );
  }
}
