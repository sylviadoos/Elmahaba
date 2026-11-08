import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_due_status.dart';

/// Homework the school set the child, as it was last edited.
class HomeworkEntity extends Equatable {
  const HomeworkEntity({
    required this.id,
    required this.title,
    required this.subject,
    this.subjectId,
    required this.description,
    this.issueDate,
    this.dueDate,
    required this.dueStatus,
    required this.isEdited,
    this.lastUpdated,
    this.attachments = const [],
    this.chatKey,
    required this.isRead,
  });

  final int id;
  final String title;

  /// e.g. "Math".
  final String subject;
  final int? subjectId;

  /// What to do; may be empty.
  final String description;

  /// The day it was given.
  final DateTime? issueDate;

  /// Null when the school gave none.
  final DateTime? dueDate;
  final HomeworkDueStatus dueStatus;
  final bool isEdited;
  final DateTime? lastUpdated;

  /// Its files: the chat's, downloaded the same way.
  final List<ChatAttachmentEntity> attachments;

  /// Its item in the chat, which marks it read.
  final String? chatKey;
  final bool isRead;

  @override
  List<Object?> get props => [
    id,
    title,
    subject,
    subjectId,
    description,
    issueDate,
    dueDate,
    dueStatus,
    isEdited,
    lastUpdated,
    attachments,
    chatKey,
    isRead,
  ];
}
