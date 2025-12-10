import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final List<HistoryItem> historyItems;

  const HistoryPage({Key? key, required this.historyItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: historyItems.isEmpty
          ? const Center(
        child: Text('No history items yet.'),
      )
          : ListView.builder(
        itemCount: historyItems.length,
        itemBuilder: (context, index) {
          final item = historyItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(item.description),
                  const SizedBox(height: 8.0),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      item.timestamp.toLocal().toString().split('.')[0], // Format timestamp
                      style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class HistoryItem {
  final String title;
  final String description;
  final DateTime timestamp;

  HistoryItem({
    required this.title,
    required this.description,
    required this.timestamp,
  });
}