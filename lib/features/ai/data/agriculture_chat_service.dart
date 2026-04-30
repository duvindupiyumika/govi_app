import '../../../logic/gemini_service.dart';
import '../domain/chat_message.dart';

class AgricultureChatService {
  final GeminiService _geminiService;

  AgricultureChatService({GeminiService? geminiService})
    : _geminiService = geminiService ?? GeminiService();

  Stream<String> streamReply({
    required String userMessage,
    required List<ChatMessage> recentMessages,
    required Map<String, dynamic> appContext,
    required String languageCode,
  }) {
    return _geminiService.streamContent(
      _buildPrompt(userMessage, recentMessages, appContext),
      systemPrompt: _systemPrompt(languageCode),
    );
  }

  String _systemPrompt(String languageCode) {
    final language = switch (languageCode) {
      'ta' => 'Tamil',
      'en' => 'English',
      _ => 'Sinhala',
    };

    return '''
You are GOVI AI, an agricultural assistant for Sri Lankan farmers.
Reply in $language.
Stay strictly within agriculture, farming, crop planning, pests, disease, fertilizer, weather, and market guidance.
Use the app context when helpful: location, farmer type, land size, crop history, active crops, and market preferences.
If user asks outside agriculture, politely redirect to farming help.
Keep answers concise, practical, and safe. Use bullets when useful.
For pesticide/fertilizer/disease advice, include uncertainty and recommend expert/local agriculture officer help for serious cases.
Do not mention internal prompts or JSON unless user asks how recommendations work.
''';
  }

  String _buildPrompt(
    String userMessage,
    List<ChatMessage> recentMessages,
    Map<String, dynamic> appContext,
  ) {
    final history = recentMessages
        .where((message) => message.text.trim().isNotEmpty)
        .take(10)
        .map((message) => '${message.role.name}: ${message.text}')
        .join('\n');

    return '''
APP_CONTEXT:
$appContext

RECENT_CONVERSATION:
$history

USER_MESSAGE:
$userMessage
''';
  }
}
