import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_ineligible_reason.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_summary_entity.dart';

/// A day the child was away, and whether a medical excuse can be sent for
/// it.
class ExcusableAbsenceEntity extends Equatable {
  const ExcusableAbsenceEntity({
    required this.attendanceId,
    required this.date,
    this.absenceReason,
    required this.canSubmit,
    this.ineligibleReason,
    this.submitUntil,
    this.excuse,
  });

  /// Names the day when sending the excuse.
  final int attendanceId;
  final DateTime date;

  /// As the school wrote it, e.g. "flu".
  final String? absenceReason;
  final bool canSubmit;

  /// Why not, when [canSubmit] is false.
  final ExcuseIneligibleReason? ineligibleReason;

  /// The last day to send one.
  final DateTime? submitUntil;

  /// The one already sent for it.
  final ExcuseSummaryEntity? excuse;

  @override
  List<Object?> get props => [
    attendanceId,
    date,
    absenceReason,
    canSubmit,
    ineligibleReason,
    submitUntil,
    excuse,
  ];
}
