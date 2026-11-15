import 'package:al_mahhaba_school/features/chat/domain/entities/chat_reply_to_entity.dart';

class ChatReplyToModel extends ChatReplyToEntity {
  const ChatReplyToModel({required super.key, required super.isDeleted});

  /// { "type": "message", "id": 41, "key": "message:41", "deleted": false }
  ///
  /// Null without a key.
  static ChatReplyToModel? fromJson(Map<String, dynamic> json) {
    final key = json['key'] as String? ?? '';
    if (key.isEmpty) return null;
    return ChatReplyToModel(
      key: key,
      isDeleted: json['deleted'] as bool? ?? false,
    );
  }
}
