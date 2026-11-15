import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/chat/data/models/chat_attachment_model.dart';
import 'package:al_mahhaba_school/features/chat/data/models/chat_audience_model.dart';
import 'package:al_mahhaba_school/features/chat/data/models/chat_child_model.dart';
import 'package:al_mahhaba_school/features/chat/data/models/chat_link_model.dart';
import 'package:al_mahhaba_school/features/chat/data/models/chat_reply_to_model.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_scope.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_sender.dart';

class ChatItemModel extends ChatItemEntity {
  const ChatItemModel({
    required super.key,
    required super.sender,
    super.sentAt,
    super.scope,
    super.audience,
    super.children,
    super.title,
    required super.text,
    super.attachments,
    super.replyTo,
    required super.isRead,
    required super.isEdited,
    required super.isDeleted,
    required super.canReply,
    super.link,
  });

  /// { "key": "message:42", "kind": "message", "sender": "parent",
  ///   "created_at": "2026-11-04T08:15:00+00:00", "scope": "general",
  ///   "audience": { …audience… } (null when private),
  ///   "children": [ …child… ], "title": null, "text": "…",
  ///   "attachments": [ …attachment… ], "reply_to": { … }, "is_read": true,
  ///   "edited": false, "deleted": false, "can_reply": false,
  ///   "related": null }
  factory ChatItemModel.fromJson(Map<String, dynamic> json) {
    final title = jsonText(json['title']);

    return ChatItemModel(
      key: json['key'] as String? ?? '',
      sender: json['sender'] == 'parent'
          ? ChatSender.parent
          : ChatSender.school,
      sentAt: DateTime.tryParse(json['created_at'] as String? ?? '')?.toLocal(),
      scope: switch (json['scope']) {
        'general' => ChatScope.general,
        'private' => ChatScope.private,
        _ => null,
      },
      audience: switch (json['audience']) {
        final Map<String, dynamic> audience => ChatAudienceModel.fromJson(
          audience,
        ),
        _ => null,
      },
      children: [
        for (final child in jsonObjects(json['children']))
          ChatChildModel.fromJson(child),
      ],
      title: title.isEmpty ? null : title,
      // As written: line breaks kept.
      text: (json['text'] as String? ?? '').trim(),
      attachments: [
        for (final attachment in jsonObjects(json['attachments']))
          ChatAttachmentModel.fromJson(attachment),
      ],
      replyTo: switch (json['reply_to']) {
        final Map<String, dynamic> replyTo => ChatReplyToModel.fromJson(
          replyTo,
        ),
        _ => null,
      },
      isRead: json['is_read'] as bool? ?? true,
      isEdited: json['edited'] as bool? ?? false,
      isDeleted: json['deleted'] as bool? ?? false,
      canReply: json['can_reply'] as bool? ?? false,
      link: switch (json['related']) {
        final Map<String, dynamic> related => ChatLinkModel.fromJson(related),
        _ => null,
      },
    );
  }
}
