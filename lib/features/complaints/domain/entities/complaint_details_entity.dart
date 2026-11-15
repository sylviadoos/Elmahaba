import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_message_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_status_change_entity.dart';

/// A complaint with what the parent wrote, its thread and its status
/// changes, oldest first.
class ComplaintDetailsEntity extends Equatable {
  const ComplaintDetailsEntity({
    required this.complaint,
    required this.description,
    required this.messages,
    required this.statusHistory,
  });

  final ComplaintEntity complaint;
  final String description;
  final List<ComplaintMessageEntity> messages;
  final List<ComplaintStatusChangeEntity> statusHistory;

  /// The message the complaint was sent with, holding its files (its words
  /// are [description]): the first, when it's the parent's without text.
  ComplaintMessageEntity? get opening {
    final first = messages.firstOrNull;
    return first != null && first.fromParent && first.text.isEmpty
        ? first
        : null;
  }

  /// The thread after [opening]: the school's replies and the parent's.
  List<ComplaintMessageEntity> get updates =>
      opening == null ? messages : messages.sublist(1);

  @override
  List<Object?> get props => [complaint, description, messages, statusHistory];
}
