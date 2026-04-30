enum ChatMessageRole { user, assistant, system }

enum ChatMessageStatus { pending, sent, failed }

class ChatMessage {
  final String id;
  final String conversationId;
  final ChatMessageRole role;
  final String text;
  final String languageCode;
  final ChatMessageStatus status;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.text,
    required this.languageCode,
    this.status = ChatMessageStatus.sent,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      role: ChatMessageRole.values.byName(json['role'] as String),
      text: json['text'] as String? ?? '',
      languageCode: json['languageCode'] as String? ?? 'si',
      status: ChatMessageStatus.values.byName(
        json['status'] as String? ?? ChatMessageStatus.sent.name,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'role': role.name,
      'text': text,
      'languageCode': languageCode,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
