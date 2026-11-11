import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/attendance/domain/entities/attendance_counts_entity.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/attendance_record_entity.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/holiday_entity.dart';

/// A child's attendance in one month. Only the days that weren't a plain
/// "present" are listed; the others are just counted.
class MonthAttendanceEntity extends Equatable {
  const MonthAttendanceEntity({
    required this.month,
    required this.counts,
    required this.records,
    required this.holidays,
    required this.weekendWeekdays,
  });

  /// Its first day.
  final DateTime month;
  final AttendanceCountsEntity counts;
  final List<AttendanceRecordEntity> records;
  final List<HolidayEntity> holidays;

  /// The days of the week the school is closed, as the school sets them —
  /// Friday and Sunday for some, Friday and Saturday for others. They're
  /// `DateTime.weekday` numbers (Monday is 1, Sunday is 7), so a day is
  /// one of them when `weekendWeekdays.contains(date.weekday)`.
  final Set<int> weekendWeekdays;

  @override
  List<Object?> get props => [
    month,
    counts,
    records,
    holidays,
    weekendWeekdays,
  ];
}
