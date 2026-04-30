import 'dart:convert';
import 'dart:typed_data';

import '../../../logic/gemini_service.dart';
import '../domain/disease_detection_result.dart';

class GeminiDiseaseService {
  final GeminiService _geminiService;

  GeminiDiseaseService({GeminiService? geminiService})
    : _geminiService = geminiService ?? GeminiService();

  Future<DiseaseDetectionResult> inspectPlant({
    required Uint8List imageBytes,
    required Map<String, dynamic> context,
    required String languageCode,
  }) async {
    final response = await _geminiService.generateContent(
      jsonEncode(context),
      imageBytes: imageBytes,
      systemPrompt: _systemPrompt(languageCode),
    );

    final json = _extractJson(response);
    return DiseaseDetectionResult.fromJson(json);
  }

  String _systemPrompt(String languageCode) {
    final language = switch (languageCode) {
      'ta' => 'Tamil',
      'en' => 'English',
      _ => 'Sinhala',
    };

    return '''
You are GOVI plant disease assistant for Sri Lankan farmers.
Analyze the plant image and app context. Reply in $language.
Return ONLY valid JSON. No markdown. No code fences. No extra text.
Do not overclaim certainty. If image is unclear, say likelyDisease is "Unclear".
Keep explanation bounded and practical.
Always recommend contacting an agriculture officer or expert when symptoms are severe, spreading, unclear, or chemical treatment is needed.

Required JSON schema:
{
  "likelyDisease": "string",
  "confidence": 0,
  "severity": "low | medium | high | unknown",
  "observedSymptoms": ["string", "string"],
  "immediateAction": "string",
  "prevention": "string",
  "expertHelpTrigger": "string",
  "warnings": ["string"]
}
''';
  }

  Map<String, dynamic> _extractJson(String response) {
    final start = response.indexOf('{');
    final end = response.lastIndexOf('}');

    if (start == -1 || end == -1 || end <= start) {
      throw const FormatException('Gemini did not return JSON.');
    }

    final decoded = jsonDecode(response.substring(start, end + 1));
    if (decoded is! Map) {
      throw const FormatException('Gemini JSON response was not an object.');
    }

    return Map<String, dynamic>.from(decoded);
  }
}
