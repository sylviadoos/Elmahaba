import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_document_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_history_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_status.dart';

/// A medical excuse in full: the day, where it stands, the school's answer,
/// its documents and what happened to it.
class ExcuseDetailsEntity extends Equatable {
  const ExcuseDetailsEntity({
    required this.id,
    required this.attendanceId,
    this.absenceDate,
    required this.status,
    this.note,
    required this.submittedByYou,
    this.submittedAt,
    this.decidedAt,
    this.rejectionReason,
    this.informationRequest,
    required this.canAddDocuments,
    required this.maxDocuments,
    this.documents = const [],
    this.history = const [],
  });

  final int id;
  final int attendanceId;
  final DateTime? absenceDate;
  final ExcuseStatus status;

  /// What the parent wrote with it.
  final String? note;

  /// False when the child's other parent sent it.
  final bool submittedByYou;
  final DateTime? submittedAt;
  final DateTime? decidedAt;

  /// Why the school turned it down.
  final String? rejectionReason;

  /// What the school asked the parent for.
  final String? informationRequest;

  /// The school asked for more: documents can be added.
  final bool canAddDocuments;
  final int maxDocuments;
  final List<ExcuseDocumentEntity> documents;

  /// Oldest first.
  final List<ExcuseHistoryEntity> history;

  @override
  List<Object?> get props => [
    id,
    attendanceId,
    absenceDate,
    status,
    note,
    submittedByYou,
    submittedAt,
    decidedAt,
    rejectionReason,
    informationRequest,
    canAddDocuments,
    maxDocuments,
    documents,
    history,
  ];
}
