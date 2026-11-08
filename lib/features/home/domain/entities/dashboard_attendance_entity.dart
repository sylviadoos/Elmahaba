import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/attendance/domain/entities/attendance_counts_entity.dart';

/// A child's attendance on Home: today's, and this month's counts.
class DashboardAttendanceEntity extends Equatable {
  const DashboardAttendanceEntity({
    this.todayStatus,
    required this.monthCounts,
  });

  /// e.g. "present"; null until today's attendance is taken.
  final String? todayStatus;
  final AttendanceCountsEntity monthCounts;

  @override
  List<Object?> get props => [todayStatus, monthCounts];
}
