import 'package:equatable/equatable.dart';

/// The parent's reply on a complaint: [text], files, or both.
class ComplaintReplyEntity extends Equatable {
  const ComplaintReplyEntity({
    required this.text,
    this.attachments = const [],
    required this.clientUuid,
  });

  /// Empty when only files are sent.
  final String text;

  /// The paths of the files sent with it (see `ComplaintAttachmentRules`).
  final List<String> attachments;

  /// Names this reply, so sending it again after a lost answer doesn't
  /// post it twice.
  final String clientUuid;

  @override
  List<Object?> get props => [text, attachments, clientUuid];
}
