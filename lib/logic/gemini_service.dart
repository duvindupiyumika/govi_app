import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<String> generateContent(
    String prompt, {
    Uint8List? imageBytes,
    String? systemPrompt,
  }) {
    return _getAiResponse(
      prompt,
      imageBytes: imageBytes,
      systemPrompt: systemPrompt,
    );
  }

  Stream<String> streamContent(String prompt, {String? systemPrompt}) async* {
    final attempts = [
      {'ver': 'v1beta', 'mod': 'gemini-3.1-flash-live-preview'},
      {'ver': 'v1beta', 'mod': 'gemini-3-flash-preview'},
      {'ver': 'v1beta', 'mod': 'gemini-2.5-pro'},
    ];

    for (final attempt in attempts) {
      final url =
          'https://generativelanguage.googleapis.com/${attempt['ver']}/models/${attempt['mod']}:streamGenerateContent?alt=sse';
      final client = http.Client();

      try {
        final request = http.Request('POST', Uri.parse(url));
        request.headers.addAll({
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        });

        final requestBody = <String, dynamic>{
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        };

        if (systemPrompt != null && systemPrompt.isNotEmpty) {
          requestBody['system_instruction'] = {
            'parts': [
              {'text': systemPrompt},
            ],
          };
        }

        request.body = jsonEncode(requestBody);
        final response = await client
            .send(request)
            .timeout(const Duration(seconds: 20));

        if (response.statusCode != 200) {
          client.close();
          continue;
        }

        var emitted = false;
        await for (final line
            in response.stream
                .transform(utf8.decoder)
                .transform(const LineSplitter())) {
          if (!line.startsWith('data:')) continue;

          final payload = line.substring(5).trim();
          if (payload.isEmpty || payload == '[DONE]') continue;

          final decoded = jsonDecode(payload) as Map<String, dynamic>;
          final candidates = decoded['candidates'] as List?;
          if (candidates == null || candidates.isEmpty) continue;

          final content = candidates.first['content'] as Map?;
          final parts = content?['parts'] as List?;
          if (parts == null || parts.isEmpty) continue;

          final text = parts.first['text'] as String?;
          if (text == null || text.isEmpty) continue;

          emitted = true;
          yield text;
        }

        client.close();
        if (emitted) return;
      } catch (_) {
        client.close();
        continue;
      }
    }

    yield 'දෝෂයකි: සම්බන්ධතාවය බිඳ වැටුණි.';
  }

  Future<String> _getAiResponse(
    String prompt, {
    Uint8List? imageBytes,
    String? systemPrompt,
  }) async {
    List<Map<String, String>> attempts = [
      {'ver': 'v1beta', 'mod': 'gemini-3.1-flash-live-preview'},
      {'ver': 'v1beta', 'mod': 'gemini-3.1-pro-preview'},
      {'ver': 'v1beta', 'mod': 'gemini-3-flash-preview'},
      {'ver': 'v1beta', 'mod': 'gemini-2.5-pro'},
    ];

    for (var attempt in attempts) {
      final url =
          'https://generativelanguage.googleapis.com/${attempt['ver']}/models/${attempt['mod']}:generateContent';
      try {
        final List<Map<String, dynamic>> parts = [
          {"text": prompt},
        ];
        if (imageBytes != null) {
          parts.add({
            "inline_data": {
              "mime_type": "image/jpeg",
              "data": base64Encode(imageBytes),
            },
          });
        }

        final Map<String, dynamic> requestBody = {
          "contents": [
            {"parts": parts},
          ],
        };

        if (systemPrompt != null && systemPrompt.isNotEmpty) {
          requestBody["system_instruction"] = {
            "parts": [
              {"text": systemPrompt},
            ],
          };
        }

        final response = await http
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'x-goog-api-key': _apiKey,
              },
              body: jsonEncode(requestBody),
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
      } catch (e) {
        continue;
      }
    }
    return "දෝෂයකි: සම්බන්ධතාවය බිඳ වැටුණි.";
  }

  Future<String> sendChatMessage(String message) async =>
      _getAiResponse(message);
  Future<String> identifyDisease(Uint8List img) async => _getAiResponse(
    "මෙම පින්තූරයේ ඇති ශාක රෝගය කුමක්ද? කරුණාකර සිංහලෙන් පවසන්න.",
    imageBytes: img,
  );
  Future<String> getCropRecommendation(
    String l,
    String p,
    String t,
  ) async => _getAiResponse(
    "මම ඉන්නේ $l හි. pH අගය $p සහ උෂ්ණත්වය $t වේ. සුදුසු බෝග 3ක් සිංහලෙන් පවසන්න.",
  );
  Future<String> getFertilizerAdvice(String c, String a) async =>
      _getAiResponse("$c වගාවේ සති $a ට සුදුසු පොහොර සිංහලෙන් පවසන්න.");
}
