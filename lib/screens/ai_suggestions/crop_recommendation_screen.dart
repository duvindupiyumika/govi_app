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
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("බෝග නිර්දේශය"), backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _buildInputField(_locController, "ඔබේ ප්‍රදේශය (උදා: අනුරාධපුරය)", Icons.location_on),
            const SizedBox(height: 15),
            _buildInputField(_phController, "පසෙහි pH අගය", Icons.science),
            const SizedBox(height: 15),
            _buildInputField(_tempController, "සාමාන්‍ය උෂ්ණත්වය", Icons.thermostat),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: _isLoading ? null : _getRecommendation,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("නිර්දේශ ලබාගන්න", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 30),
            if (_result.isNotEmpty) _buildResultSection(_result),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true, fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildResultSection(String result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Icon(Icons.auto_awesome, color: Colors.green), SizedBox(width: 10), Text("AI උපදෙස්", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
          const Divider(),
          Text(result, style: const TextStyle(fontSize: 16, height: 1.6)),
        ],
      ),
    );
  }
}