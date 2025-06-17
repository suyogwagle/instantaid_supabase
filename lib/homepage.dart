import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome People")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 200.0,
              height: 300.0,
              child: Card(child: Text('Hello World!')),
            ),
          ],
        ),
      ),
    );
  }
}
