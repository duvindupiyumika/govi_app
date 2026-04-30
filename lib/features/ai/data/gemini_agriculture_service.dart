import 'dart:convert';

import '../../../logic/gemini_service.dart';
import '../domain/crop_suggestion_result.dart';

class GeminiAgricultureService {
  final GeminiService _geminiService;

  GeminiAgricultureService({GeminiService? geminiService})
    : _geminiService = geminiService ?? GeminiService();

  Future<CropSuggestionResult> suggestCrop({
    required Map<String, dynamic> context,
    required String languageCode,
  }) async {
    final response = await _geminiService.generateContent(
      jsonEncode(context),
      systemPrompt: _systemPrompt(languageCode),
    );

    final json = _extractJson(response);
    return CropSuggestionResult.fromJson(json);
  }

  String _systemPrompt(String languageCode) {
    final language = switch (languageCode) {
      'ta' => 'Tamil',
      'en' => 'English',
      _ => 'Sinhala',
    };

    return '''
You are GOVI, an agricultural decision-support assistant for Sri Lankan farmers.
Stay strictly within agriculture, crop planning, farming risk, and market guidance.
Use the farmer context JSON sent by the app. If a value is missing, reason cautiously.
Respond in $language.
Return ONLY valid JSON. No markdown. No code fences. No extra explanation.
Keep every text field short and farmer-friendly.

Required JSON schema:
{
  "recommendedCrop": "string",
  "confidence": 0,
  "reasonSummary": "string",
  "marketRisk": "string",
  "weatherFit": "string",
  "soilRotationNote": "string",
  "expectedHarvestWindow": "string",
  "actions": ["string", "string", "string"],
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

    final jsonText = response.substring(start, end + 1);
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map) {
      throw const FormatException('Gemini JSON response was not an object.');
    }

    return Map<String, dynamic>.from(decoded);
  }
}
