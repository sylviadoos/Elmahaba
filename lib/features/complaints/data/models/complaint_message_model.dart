import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_attachment_model.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_message_entity.dart';

class ComplaintMessageModel extends ComplaintMessageEntity {
  const ComplaintMessageModel({
    required super.id,
    required super.fromParent,
    required super.senderName,
    required super.text,
    required super.attachments,
    super.sentAt,
  });

  /// { "id": 30, "sender": "parent", "sender_name": null, "text": null,
  ///   "attachments": [ …attachment… ],
  ///   "created_at": "2026-11-03T09:15:00+02:00" }
  factory ComplaintMessageModel.fromJson(Map<String, dynamic> json) =>
      ComplaintMessageModel(
        id: json['id'] as int? ?? 0,
        fromParent: json['sender'] == 'parent',
        senderName: jsonText(json['sender_name']),
        // As written: line breaks kept.
        text: (json['text'] as String? ?? '').trim(),
        attachments: [
          for (final attachment in jsonObjects(json['attachments']))
            ComplaintAttachmentModel.fromJson(attachment),
        ],
        sentAt: DateTime.tryParse(
          json['created_at'] as String? ?? '',
        )?.toLocal(),
      );
}
