import 'package:equatable/equatable.dart';

/// A child's attendance on Home: today's, and the days they came.
class DashboardAttendanceEntity extends Equatable {
  const DashboardAttendanceEntity({this.todayStatus, this.presentDays = 0});

  /// e.g. "absent"; null until today's attendance is taken.
  final String? todayStatus;

  /// How many days the child came to school.
  final int presentDays;

  @override
  List<Object?> get props => [todayStatus, presentDays];
}
