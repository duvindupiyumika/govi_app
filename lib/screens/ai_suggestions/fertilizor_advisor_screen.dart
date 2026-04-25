import 'package:flutter/material.dart';
import '../../logic/gemini_service.dart';

class FertilizerAdvisorScreen extends StatefulWidget {
  const FertilizerAdvisorScreen({super.key});
  @override
  State<FertilizerAdvisorScreen> createState() => _FertilizerAdvisorScreenState();
}

class _FertilizerAdvisorScreenState extends State<FertilizerAdvisorScreen> {
  final _cropController = TextEditingController();
  final _ageController = TextEditingController();
  String _result = "";
  bool _isLoading = false;

  void _getAdvice() async {
    setState(() => _isLoading = true);
    try {
      final res = await GeminiService().getFertilizerAdvice(_cropController.text, _ageController.text);
      setState(() => _result = res);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("පොහොර උපදේශක"), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _cropController, decoration: const InputDecoration(labelText: "වගාව")),
              TextField(controller: _ageController, decoration: const InputDecoration(labelText: "වගාවේ වයස (සති)")),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _getAdvice, child: const Text("උපදෙස් ලබාගන්න")),
              const SizedBox(height: 20),
              if (_isLoading) const CircularProgressIndicator(color: Colors.green),
              Text(_result, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}