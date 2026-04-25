import 'package:flutter/material.dart';
import '../../logic/gemini_service.dart';

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});
  @override
  State<CropRecommendationScreen> createState() => _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  final _locController = TextEditingController();
  final _phController = TextEditingController();
  final _tempController = TextEditingController();
  String _result = "";
  bool _isLoading = false;

  void _getRecommendation() async {
    setState(() => _isLoading = true);
    try {
      final res = await GeminiService().getCropRecommendation(_locController.text, _phController.text, _tempController.text);
      setState(() => _result = res);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("බෝග නිර්දේශය"), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _locController, decoration: const InputDecoration(labelText: "ප්‍රදේශය")),
              TextField(controller: _phController, decoration: const InputDecoration(labelText: "පසෙහි pH අගය")),
              TextField(controller: _tempController, decoration: const InputDecoration(labelText: "සාමාන්‍ය උෂ්ණත්වය")),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _getRecommendation, child: const Text("නිර්දේශ ලබාගන්න")),
              const Divider(height: 40),
              if (_isLoading) const CircularProgressIndicator(color: Colors.green),
              Text(_result, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}