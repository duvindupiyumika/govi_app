import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../features/ai/data/ai_prediction_repository.dart';
import '../../features/ai/data/gemini_disease_service.dart';
import '../../features/ai/domain/ai_prediction.dart';
import '../../features/ai/domain/disease_detection_result.dart';
import '../profile/theme_provider.dart';

class DiseaseScanScreen extends StatefulWidget {
  const DiseaseScanScreen({super.key});

  @override
  State<DiseaseScanScreen> createState() => _DiseaseScanScreenState();
}

class _DiseaseScanScreenState extends State<DiseaseScanScreen> {
  final _picker = ImagePicker();
  final _questionController = TextEditingController();
  final _diseaseService = GeminiDiseaseService();
  final _predictionRepository = AiPredictionRepository();
  final _uuid = const Uuid();

  Uint8List? _imageBytes;
  String? _imageSource;
  DiseaseDetectionResult? _result;
  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final latest = _predictionRepository.latestByType('disease_detection');
    if (latest != null) {
      _result = DiseaseDetectionResult.fromJson(latest.output);
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 1200,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imageSource = source.name;
      _result = null;
      _error = null;
    });
  }

  Future<void> _inspectPlant() async {
    final imageBytes = _imageBytes;
    if (imageBytes == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final provider = context.read<ThemeProvider>();
    final contextData = {
      'farmer': {
        'languageCode': provider.languageCode,
        'location': provider.profile.location,
        'farmerType': provider.profile.farmerType,
      },
      'imageSource': _imageSource,
      'question': _questionController.text.trim(),
      'responseGoal':
          'Identify likely disease or issue from image and provide bounded practical guidance.',
    };

    try {
      final result = await _diseaseService.inspectPlant(
        imageBytes: imageBytes,
        context: contextData,
        languageCode: provider.languageCode,
      );

      final prediction = AiPrediction(
        id: _uuid.v4(),
        type: 'disease_detection',
        input: {
          ...contextData,
          'imageSaved': false,
          'note': 'Image/video not saved; only text interaction is stored.',
        },
        output: result.toJson(),
        languageCode: provider.languageCode,
        createdAt: DateTime.now(),
      );
      await _predictionRepository.save(prediction.id, prediction);

      if (!mounted) return;
      setState(() => _result = result);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'Could not inspect the plant image. Try a clearer photo or check connection.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Plant Disease Check'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSafetyNote(),
            const SizedBox(height: 16),
            _buildImagePreview(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _questionController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Question or observation (optional)',
                hintText:
                    'Example: Leaves are curling and yellow spots spread...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _imageBytes == null || _isLoading
                  ? null
                  : _inspectPlant,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isLoading ? 'Inspecting...' : 'Inspect plant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              _buildError(_error!),
            ],
            if (_result != null) ...[
              const SizedBox(height: 20),
              _buildResult(_result!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'AI inspection is guidance only. For severe disease, spreading symptoms, or chemical treatment, contact an agriculture officer.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: _imageBytes == null
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 54,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text('Take or choose a clear plant photo'),
                  ],
                ),
              )
            : Image.memory(_imageBytes!, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }

  Widget _buildResult(DiseaseDetectionResult result) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.health_and_safety,
                color: Colors.orange,
                size: 32,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.likelyDisease,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _Badge(label: '${result.confidence}%'),
            ],
          ),
          const SizedBox(height: 10),
          _Badge(label: 'Severity: ${result.severity}'),
          const Divider(height: 28),
          if (result.observedSymptoms.isNotEmpty) ...[
            const Text(
              'Observed symptoms',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...result.observedSymptoms.map((symptom) => Text('• $symptom')),
            const SizedBox(height: 14),
          ],
          _ResultSection(
            title: 'Immediate action',
            value: result.immediateAction,
          ),
          _ResultSection(title: 'Prevention', value: result.prevention),
          _ResultSection(
            title: 'When to get expert help',
            value: result.expertHelpTrigger,
          ),
          if (result.warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Warnings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...result.warnings.map((warning) => Text('• $warning')),
          ],
        ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  final String title;
  final String value;

  const _ResultSection({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
