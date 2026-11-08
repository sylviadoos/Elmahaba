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
  });

  /// Its first day.
  final DateTime month;
  final AttendanceCountsEntity counts;
  final List<AttendanceRecordEntity> records;
  final List<HolidayEntity> holidays;

  @override
  List<Object?> get props => [month, counts, records, holidays];
}
