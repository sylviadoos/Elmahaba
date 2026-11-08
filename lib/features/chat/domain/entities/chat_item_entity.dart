import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_audience_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_child_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_link_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_reply_to_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_scope.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_sender.dart';

/// One thing in the chat: a message (the school's or the parent's) or
/// something the school recorded, such as an absence, a result or a fee.
class ChatItemEntity extends Equatable {
  const ChatItemEntity({
    required this.key,
    required this.sender,
    this.sentAt,
    this.scope,
    this.audience,
    this.children = const [],
    this.title,
    required this.text,
    this.attachments = const [],
    this.replyTo,
    required this.isRead,
    required this.isEdited,
    required this.isDeleted,
    required this.canReply,
    this.link,
  });

  /// e.g. "message:41" or "event:33": names it to mark it read or answer it.
  final String key;
  final ChatSender sender;
  final DateTime? sentAt;

  /// General or private, as the school says; null when it doesn't.
  final ChatScope? scope;

  /// For a general item, the parents it went to; null when the school
  /// doesn't say.
  final ChatAudienceEntity? audience;

  /// The children it's about; none for one sent to all parents.
  final List<ChatChildEntity> children;

  /// e.g. "Absence recorded"; messages usually have none.
  final String? title;
  final String text;
  final List<ChatAttachmentEntity> attachments;

  /// The item it answers.
  final ChatReplyToEntity? replyTo;
  final bool isRead;
  final bool isEdited;

  /// Taken down: its text and files are gone.
  final bool isDeleted;

  /// The parent may answer it.
  final bool canReply;

  /// The screen it opens.
  final ChatLinkEntity? link;

  /// As the school says; else, not about any child.
  bool get isGeneral => switch (scope) {
    ChatScope.general => true,
    ChatScope.private => false,
    null => children.isEmpty,
  };

  bool get fromParent => sender == ChatSender.parent;

  @override
  List<Object?> get props => [
    key,
    sender,
    sentAt,
    scope,
    audience,
    children,
    title,
    text,
    attachments,
    replyTo,
    isRead,
    isEdited,
    isDeleted,
    canReply,
    link,
  ];
}
