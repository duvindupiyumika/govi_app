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
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("පොහොර උපදේශක"), backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _buildInputField(_cropController, "වගාව (උදා: වී, බඩඉරිඟු)", Icons.eco),
            const SizedBox(height: 15),
            _buildInputField(_ageController, "වගාවේ වයස (සති)", Icons.calendar_today),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: _isLoading ? null : _getAdvice,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("උපදෙස් ලබාගන්න", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 30),
            if (_result.isNotEmpty) 
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.purple.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.purple.withOpacity(0.3))),
                child: Text(_result, style: const TextStyle(fontSize: 16, height: 1.6)),
              ),
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
        prefixIcon: Icon(icon, color: Colors.purple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true, fillColor: Colors.grey[50],
      ),
    );
  }
}