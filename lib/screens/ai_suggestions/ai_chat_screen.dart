import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../features/ai/data/agriculture_chat_service.dart';
import '../../features/ai/data/chat_repository.dart';
import '../../features/ai/domain/chat_message.dart';
import '../../features/onboarding/data/onboarding_repository.dart';
import '../../features/tracking/data/crop_plan_repository.dart';
import '../profile/theme_provider.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  static const _conversationId = 'default_agriculture_chat';

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _chatRepository = ChatRepository();
  final _chatService = AgricultureChatService();
  final _onboardingRepository = OnboardingRepository();
  final _cropPlanRepository = CropPlanRepository();
  final _uuid = const Uuid();

  String _responseLanguageCode = 'si';
  bool _isStreaming = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final providerLanguage = context.read<ThemeProvider>().languageCode;
    if (_responseLanguageCode == 'si') {
      _responseLanguageCode = providerLanguage;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage({String? retryText}) async {
    final text = (retryText ?? _controller.text).trim();
    if (text.isEmpty || _isStreaming) return;

    _controller.clear();
    final now = DateTime.now();
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      conversationId: _conversationId,
      role: ChatMessageRole.user,
      text: text,
      languageCode: _responseLanguageCode,
      createdAt: now,
    );
    final assistantMessage = ChatMessage(
      id: _uuid.v4(),
      conversationId: _conversationId,
      role: ChatMessageRole.assistant,
      text: '',
      languageCode: _responseLanguageCode,
      status: ChatMessageStatus.pending,
      createdAt: now.add(const Duration(milliseconds: 1)),
    );

    await _chatRepository.save(userMessage.id, userMessage, queueSync: false);
    await _chatRepository.save(
      assistantMessage.id,
      assistantMessage,
      queueSync: false,
    );
    _scrollToBottom();

    setState(() => _isStreaming = true);

    final contextData = _buildAppContext();
    final recentMessages = _chatRepository.messagesForConversation(
      _conversationId,
    );
    var streamedText = '';

    try {
      await for (final chunk in _chatService.streamReply(
        userMessage: text,
        recentMessages: recentMessages,
        appContext: contextData,
        languageCode: _responseLanguageCode,
      )) {
        streamedText += chunk;
        await _chatRepository.save(
          assistantMessage.id,
          assistantMessage.copyWith(text: streamedText),
          queueSync: false,
        );
        _scrollToBottom();
      }

      await _chatRepository.save(
        assistantMessage.id,
        assistantMessage.copyWith(
          text: streamedText.isEmpty
              ? 'No response received. Please try again.'
              : streamedText,
          status: streamedText.isEmpty
              ? ChatMessageStatus.failed
              : ChatMessageStatus.sent,
        ),
        queueSync: false,
      );
    } catch (_) {
      await _chatRepository.save(
        assistantMessage.id,
        assistantMessage.copyWith(
          text: 'Connection failed. Please retry.',
          status: ChatMessageStatus.failed,
        ),
        queueSync: false,
      );
    } finally {
      if (mounted) setState(() => _isStreaming = false);
      _scrollToBottom();
    }
  }

  Map<String, dynamic> _buildAppContext() {
    final profile = context.read<ThemeProvider>().profile;
    final onboarding = _onboardingRepository.getById('local');
    final cropPlans = _cropPlanRepository.getAll();

    return {
      'profile': {
        'farmerType': profile.farmerType ?? onboarding?.farmerType,
        'location': profile.location ?? onboarding?.location,
        'landSize': profile.landSize ?? onboarding?.landSize,
        'languageCode': profile.languageCode,
      },
      'cropHistory': onboarding?.previousCrops ?? const [],
      'marketPreferences': onboarding?.marketPreferences ?? const [],
      'activeCrops': cropPlans
          .map(
            (plan) => {
              'cropName': plan.cropName,
              'location': plan.location,
              'startDate': plan.startDate.toIso8601String(),
              'expectedHarvestDate': plan.expectedHarvestDate.toIso8601String(),
            },
          )
          .toList(),
    };
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'AI සහායක',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Response language',
            initialValue: _responseLanguageCode,
            onSelected: (value) =>
                setState(() => _responseLanguageCode = value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'si', child: Text('සිංහල')),
              PopupMenuItem(value: 'ta', child: Text('தமிழ்')),
              PopupMenuItem(value: 'en', child: Text('English')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(child: Text(_languageLabel(_responseLanguageCode))),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatRepository.watchConversation(_conversationId),
              builder: (context, snapshot) {
                final messages =
                    snapshot.data ??
                    _chatRepository.messagesForConversation(_conversationId);

                if (messages.isEmpty) {
                  return const _EmptyChatState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(15),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _MessageBubble(
                      message: message,
                      onRetry: () => _sendMessage(
                        retryText: _previousUserMessage(messages, index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isStreaming)
            const LinearProgressIndicator(color: Colors.green, minHeight: 2),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'ප්‍රශ්නය විමසන්න...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: const Color(0xFF1B5E20),
              child: IconButton(
                onPressed: _isStreaming ? null : () => _sendMessage(),
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _languageLabel(String code) {
    return switch (code) {
      'ta' => 'TA',
      'en' => 'EN',
      _ => 'SI',
    };
  }

  String _previousUserMessage(List<ChatMessage> messages, int assistantIndex) {
    for (var index = assistantIndex - 1; index >= 0; index--) {
      if (messages[index].role == ChatMessageRole.user) {
        return messages[index].text;
      }
    }
    return '';
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, size: 72, color: Colors.green[300]),
            const SizedBox(height: 16),
            const Text(
              'Ask GOVI anything about farming',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'GOVI uses your saved location, farmer type, crop history, and active crops to keep answers practical.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onRetry;

  const _MessageBubble({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatMessageRole.user;
    final isFailed = message.status == ChatMessageStatus.failed;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(15),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isUser ? const Radius.circular(15) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(15),
          ),
          border: isFailed ? Border.all(color: Colors.red.shade200) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.status == ChatMessageStatus.pending &&
                message.text.isEmpty)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                message.text,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
                if (isFailed) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onRetry,
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
