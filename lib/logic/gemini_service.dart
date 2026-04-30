import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<String> _getAiResponse(String prompt, {Uint8List? imageBytes, String? systemPrompt}) async {
    List<Map<String, String>> attempts = [
      {'ver': 'v1beta', 'mod': 'gemini-3.1-flash-live-preview'},
      {'ver': 'v1beta', 'mod': 'gemini-3.1-pro-preview'},
      {'ver': 'v1beta', 'mod': 'gemini-3-flash-preview'},
      {'ver': 'v1beta', 'mod': 'gemini-2.5-pro'},
    ];

    for (var attempt in attempts) {
      final url = 'https://generativelanguage.googleapis.com/${attempt['ver']}/models/${attempt['mod']}:generateContent';
      try {
        final List<Map<String, dynamic>> parts = [{"text": prompt}];
        if (imageBytes != null) {
          parts.add({"inline_data": {"mime_type": "image/jpeg", "data": base64Encode(imageBytes)}});
        }

        final Map<String, dynamic> requestBody = {
          "contents": [{"parts": parts}]
        };

        if (systemPrompt != null && systemPrompt.isNotEmpty) {
          requestBody["system_instruction"] = {
            "parts": [{"text": systemPrompt}]
          };
        }

        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': _apiKey
          },
          body: jsonEncode(requestBody),
        ).timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
      } catch (e) { continue; }
    }
    return "දෝෂයකි: සම්බන්ධතාවය බිඳ වැටුණි.";
  }

  Future<String> sendChatMessage(String message) async => _getAiResponse(message);
  Future<String> identifyDisease(Uint8List img) async => _getAiResponse("මෙම පින්තූරයේ ඇති ශාක රෝගය කුමක්ද? කරුණාකර සිංහලෙන් පවසන්න.", imageBytes: img);
  Future<String> getCropRecommendation(String l, String p, String t) async => _getAiResponse("මම ඉන්නේ $l හි. pH අගය $p සහ උෂ්ණත්වය $t වේ. සුදුසු බෝග 3ක් සිංහලෙන් පවසන්න.");
  Future<String> getFertilizerAdvice(String c, String a) async => _getAiResponse("$c වගාවේ සති $a ට සුදුසු පොහොර සිංහලෙන් පවසන්න.");
}