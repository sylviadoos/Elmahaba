import 'package:equatable/equatable.dart';

/// A child's school days in a month, by how they were recorded.
class AttendanceCountsEntity extends Equatable {
  const AttendanceCountsEntity({
    required this.presentDays,
    required this.absentDays,
    this.lateDays = 0,
    required this.excusedDays,
  });

  /// The days the child came on time.
  final int presentDays;
  final int absentDays;

  /// The days the child came, late.
  final int lateDays;

  /// Absences with an excuse or a medical note.
  final int excusedDays;

  /// Every day attendance was taken.
  int get schoolDays => presentDays + absentDays + lateDays + excusedDays;

  /// The days the child came, late or not.
  int get attendedDays => presentDays + lateDays;

  @override
  List<Object?> get props => [presentDays, absentDays, lateDays, excusedDays];
}
