import 'package:equatable/equatable.dart';

/// A message the parent is sending the school.
class NewChatMessageEntity extends Equatable {
  const NewChatMessageEntity({
    this.studentId,
    required this.text,
    this.replyTo,
    this.attachments = const [],
    required this.clientUuid,
  });

  /// The child it's about; null for none of them (a general message).
  final int? studentId;

  /// Empty when only files are sent.
  final String text;

  /// The `key` of the item it answers.
  final String? replyTo;

  /// The paths of the files sent with it (the same rules as a complaint's,
  /// see `ComplaintAttachmentRules`).
  final List<String> attachments;

  /// Names this message, so sending it again after a lost answer doesn't
  /// post it twice.
  final String clientUuid;

  @override
  List<Object?> get props => [
    studentId,
    text,
    replyTo,
    attachments,
    clientUuid,
  ];
}
