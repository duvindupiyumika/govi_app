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
      appBar: AppBar(title: const Text("රෝග විනිශ්චය"), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_imageBytes != null) Image.memory(_imageBytes!, height: 250, width: double.infinity, fit: BoxFit.cover)
            else Container(height: 250, color: Colors.grey[200], child: const Icon(Icons.camera_alt, size: 100, color: Colors.grey)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ElevatedButton(onPressed: _pickImage, child: const Text("ඡායාරූපයක් තෝරන්න")),
                  const SizedBox(height: 20),
                  if (_isLoading) const CircularProgressIndicator(color: Colors.green),
                  Text(_result, style: const TextStyle(fontSize: 16, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}