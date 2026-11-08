import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/attendance/domain/entities/attendance_status.dart';

/// A school day that wasn't a plain "present": absent, late or excused.
class AttendanceRecordEntity extends Equatable {
  const AttendanceRecordEntity({
    required this.date,
    required this.status,
    this.reason,
  });

  final DateTime date;
  final AttendanceStatus status;

  /// As written, e.g. "sick" or "Arrived at 8:20"; null when none was
  /// given — an absence without one waits for the parent's reply.
  final String? reason;

  @override
  List<Object?> get props => [date, status, reason];
}
