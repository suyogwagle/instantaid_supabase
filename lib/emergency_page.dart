import 'package:flutter/material.dart';

class EmergencyModeScreen extends StatelessWidget {
  const EmergencyModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Emergency Mode"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat area
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  // Example bubble
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ChatBubble(
                      text: "K xa haalkhabar",
                      isUser: false,
                    ),
                  ),
                ],
              ),
            ),

            // Input area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  // Image input button
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.image_search_rounded, size: 28),
                  ),

                  // Text input box
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Describe your symptoms...",
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                      ),
                    ),
                  ),

                  // Voice input
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.mic_rounded, size: 28),
                  ),

                  // Send button
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.send_rounded, size: 26),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isUser ? Colors.blue : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isUser ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      ),
    );
  }
}