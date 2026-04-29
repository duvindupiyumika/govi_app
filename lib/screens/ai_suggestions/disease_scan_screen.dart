import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../logic/gemini_service.dart';

class DiseaseScanScreen extends StatefulWidget {
  const DiseaseScanScreen({super.key});
  @override
  State<DiseaseScanScreen> createState() => _DiseaseScanScreenState();
}

class _DiseaseScanScreenState extends State<DiseaseScanScreen> {
  final GeminiService _service = GeminiService();
  Uint8List? _imageBytes;
  String _result = "";
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() { _imageBytes = bytes; _result = ""; _isLoading = true; });
      try {
        final res = await _service.identifyDisease(bytes);
        setState(() => _result = res);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("රෝග විනිශ්චය"), backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250, width: double.infinity,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: _imageBytes != null ? Image.memory(_imageBytes!, fit: BoxFit.cover) : const Center(child: Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    onPressed: _pickImage, icon: const Icon(Icons.camera_alt, color: Colors.white), label: const Text("ඡායාරූපයක් තෝරන්න", style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 25),
                  if (_isLoading) const CircularProgressIndicator(color: Colors.green),
                  if (_result.isNotEmpty) 
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange.withOpacity(0.3))),
                      child: Text(_result, style: const TextStyle(fontSize: 16, height: 1.6)),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}