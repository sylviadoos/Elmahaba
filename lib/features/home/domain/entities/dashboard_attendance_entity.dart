import 'package:equatable/equatable.dart';

/// A child's attendance on Home: today's, and the days they may be absent
/// this year.
class DashboardAttendanceEntity extends Equatable {
  const DashboardAttendanceEntity({
    this.todayStatus,
    this.allowedAbsenceDays = 0,
    this.actualAbsenceDays = 0,
    this.remainingAbsenceDays = 0,
    this.exceededAbsenceDays = 0,
  });

  /// e.g. "absent"; null until today's attendance is taken.
  final String? todayStatus;

  /// How many days the school allows; 0 when it sets no limit.
  final int allowedAbsenceDays;

  /// How many the child was absent.
  final int actualAbsenceDays;

  /// How many are left before the limit.
  final int remainingAbsenceDays;

  /// How many past the limit.
  final int exceededAbsenceDays;

  @override
  List<Object?> get props => [
    todayStatus,
    allowedAbsenceDays,
    actualAbsenceDays,
    remainingAbsenceDays,
    exceededAbsenceDays,
  ];
}
