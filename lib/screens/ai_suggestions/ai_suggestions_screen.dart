import 'package:flutter/material.dart';

class AiSuggestionsScreen extends StatelessWidget {
  const AiSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Suggestions'),
      ),
      body: const Center(
        child: Text(
          'AI Suggestions Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}