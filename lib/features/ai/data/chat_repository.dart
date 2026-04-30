import '../../../core/storage/hive_box_names.dart';
import '../../../core/storage/json_box_repository.dart';
import '../domain/chat_message.dart';

class ChatRepository extends JsonBoxRepository<ChatMessage> {
  ChatRepository({super.syncManager})
    : super(
        boxName: HiveBoxNames.chatMessages,
        entityType: 'chat_message',
        fromJson: ChatMessage.fromJson,
        toJson: (message) => message.toJson(),
      );
}
