import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

class GeminiService {
   static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  final _model = GenerativeModel(
    model: 'gemini-3-flash-preview', 
    apiKey: _apiKey,
  );

  Future<String> _getAiResponse(String prompt, {Uint8List? imageBytes}) async {
    try {
      final content = [
        Content.multi([
          TextPart(prompt),
          if (imageBytes != null) DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      return response.text ?? "පිළිතුරක් ලබා ගැනීමට නොහැකි විය.";
    } catch (e) {
      return "දෝෂයකි: $e";
    }
  }

  Future<String> getCropRecommendation(String location, String ph, String temp) async {
    return _getAiResponse("මම ඉන්නේ $location ප්‍රදේශයේ. පසෙහි pH අගය $ph සහ උෂ්ණත්වය $temp වේ. මෙහි වගා කිරීමට වඩාත්ම සුදුසු බෝග 3ක් සහ හේතු සිංහලෙන් පවසන්න.");
  }

  Future<String> getFertilizerAdvice(String crop, String age) async {
    return _getAiResponse("මගේ $crop වගාවට දැන් වයස සති $age කි. මෙයට දැන් යෙදිය යුතු හොඳම පොහොර සහ ප්‍රමාණය සිංහලෙන් පවසන්න.");
  }

  Future<String> identifyDisease(Uint8List imageBytes) async {
    return _getAiResponse(
      "මෙම පින්තූරයේ ඇති ශාක රෝගය කුමක්ද? එයට ගත යුතු පිළියම් මොනවාද? කරුණාකර සිංහලෙන් පැහැදිලි කරන්න.",
      imageBytes: imageBytes,
    );
  }
}