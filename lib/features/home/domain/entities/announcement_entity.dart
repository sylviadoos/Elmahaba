import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_audience_entity.dart';

/// A school announcement for the parents, as the chat shows it.
class AnnouncementEntity extends Equatable {
  const AnnouncementEntity({
    required this.id,
    required this.title,
    required this.body,
    this.publishedAt,
    this.expiresAt,
    this.isExpired = false,
    this.isEdited = false,
    this.attachments = const [],
    this.audience,
    this.chatKey,
    this.isRead = true,
  });

  final int id;

  /// As the school wrote them, in either language.
  final String title;
  final String body;

  final DateTime? publishedAt;

  /// Null when it doesn't expire.
  final DateTime? expiresAt;
  final bool isExpired;
  final bool isEdited;
  final List<ChatAttachmentEntity> attachments;

  /// The parents it went to, e.g. all of them.
  final ChatAudienceEntity? audience;

  /// The item in the chat, e.g. "event:47".
  final String? chatKey;
  final bool isRead;

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    publishedAt,
    expiresAt,
    isExpired,
    isEdited,
    attachments,
    audience,
    chatKey,
    isRead,
  ];
}
