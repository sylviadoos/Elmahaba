import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/chat/data/models/chat_attachment_model.dart';
import 'package:al_mahhaba_school/features/chat/data/models/chat_audience_model.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';

class AnnouncementModel extends AnnouncementEntity {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.body,
    super.publishedAt,
    super.expiresAt,
    super.isExpired,
    super.isEdited,
    super.attachments,
    super.audience,
    super.chatKey,
    super.isRead,
  });

  /// { "id": 3, "title": "…", "body": "…",
  ///   "published_at": "2026-11-05T13:11:55+00:00", "expires_at": null,
  ///   "expired": false, "edited": false, "last_updated": null,
  ///   "attachments": [ …file… ], "scope": "general",
  ///   "audience": { "type": "all", "name": "All parents",
  ///   "name_ar": "كل أولياء الأمور" }, "chat_key": "event:47",
  ///   "is_read": true }
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      AnnouncementModel(
        id: json['id'] as int? ?? 0,
        title: jsonText(json['title']),
        body: jsonText(json['body']),
        publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
        expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? ''),
        isExpired: json['expired'] as bool? ?? false,
        isEdited: json['edited'] as bool? ?? false,
        attachments: [
          for (final file in jsonObjects(json['attachments']))
            ChatAttachmentModel.fromJson(file),
        ],
        audience: switch (json['audience']) {
          final Map<String, dynamic> audience => ChatAudienceModel.fromJson(
            audience,
          ),
          _ => null,
        },
        chatKey: jsonTextOrNull(json['chat_key']),
        // Not said: nothing to mark.
        isRead: json['is_read'] as bool? ?? true,
      );
}
