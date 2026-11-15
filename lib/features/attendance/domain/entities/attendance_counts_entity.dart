import 'package:equatable/equatable.dart';

/// A child's school days in a month, by how they were recorded. A late
/// arrival counts as present: the child came.
class AttendanceCountsEntity extends Equatable {
  const AttendanceCountsEntity({
    required this.presentDays,
    required this.absentDays,
    required this.excusedDays,
  });

  /// The days the child came, on time or late.
  final int presentDays;
  final int absentDays;

  /// Absences with an excuse or a medical note.
  final int excusedDays;

  /// Every day attendance was taken.
  int get schoolDays => presentDays + absentDays + excusedDays;

  /// The days the child came.
  int get attendedDays => presentDays;

  @override
  List<Object?> get props => [presentDays, absentDays, excusedDays];
}
