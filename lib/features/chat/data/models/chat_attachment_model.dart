import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';

class ChatAttachmentModel extends ChatAttachmentEntity {
  const ChatAttachmentModel({
    required super.id,
    required super.fileName,
    required super.mimeType,
    required super.size,
    required super.isAvailable,
  });

  /// { "id": 77, "file_name": "trip-form.pdf", "mime": "application/pdf",
  ///   "size": 84211, "status": "available" }
  factory ChatAttachmentModel.fromJson(Map<String, dynamic> json) =>
      ChatAttachmentModel(
        id: json['id'] as int? ?? 0,
        fileName: json['file_name'] as String? ?? '',
        mimeType: json['mime'] as String? ?? '',
        size: json['size'] as int? ?? 0,
        isAvailable: json['status'] == 'available',
      );
}
