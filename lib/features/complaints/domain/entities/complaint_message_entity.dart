import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_attachment_entity.dart';

/// One message in a complaint's thread: the parent's or the school's.
class ComplaintMessageEntity extends Equatable {
  const ComplaintMessageEntity({
    required this.id,
    required this.fromParent,
    required this.senderName,
    required this.text,
    required this.attachments,
    this.sentAt,
  });

  final int id;
  final bool fromParent;

  /// Who at the school wrote it, e.g. "Transport office"; empty when not
  /// given (and for the parent's own).
  final String senderName;

  /// Empty for files only.
  final String text;
  final List<ComplaintAttachmentEntity> attachments;
  final DateTime? sentAt;

  @override
  List<Object?> get props => [
    id,
    fromParent,
    senderName,
    text,
    attachments,
    sentAt,
  ];
}
