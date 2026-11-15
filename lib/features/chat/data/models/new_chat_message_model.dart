import 'package:dio/dio.dart';

import 'package:al_mahhaba_school/core/network/multipart_files.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/new_chat_message_entity.dart';

/// [NewChatMessageEntity] as sent to `POST v1/parent/chat/messages`.
class NewChatMessageModel extends NewChatMessageEntity {
  const NewChatMessageModel({
    super.studentId,
    required super.text,
    super.replyTo,
    super.attachments,
    required super.clientUuid,
  });

  factory NewChatMessageModel.fromEntity(NewChatMessageEntity entity) =>
      NewChatMessageModel(
        studentId: entity.studentId,
        text: entity.text,
        replyTo: entity.replyTo,
        attachments: entity.attachments,
        clientUuid: entity.clientUuid,
      );

  /// student_id ("general" when it's about none of the children), text
  /// (left out when empty), client_uuid, reply_to (when answering) and one
  /// `attachments[]` per file.
  Future<FormData> toFormData() async => FormData()
    ..fields.addAll([
      MapEntry('student_id', '${studentId ?? 'general'}'),
      if (text.isNotEmpty) MapEntry('text', text),
      MapEntry('client_uuid', clientUuid),
      if (replyTo case final replyTo?) MapEntry('reply_to', replyTo),
    ])
    ..files.addAll(await multipartFiles('attachments[]', attachments));
}
