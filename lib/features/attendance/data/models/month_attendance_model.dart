import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/attendance/data/models/attendance_counts_model.dart';
import 'package:al_mahhaba_school/features/attendance/data/models/attendance_record_model.dart';
import 'package:al_mahhaba_school/features/attendance/data/models/holiday_model.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/month_attendance_entity.dart';

/// The `data` of `GET v1/parent/children/{child_id}/attendance?month=…`.
///
/// Missing counts read as 0, and missing lists as empty; a record or
/// holiday without a readable date is left out.
class MonthAttendanceModel extends MonthAttendanceEntity {
  const MonthAttendanceModel({
    required super.month,
    required super.counts,
    required super.records,
    required super.holidays,
    required super.weekendWeekdays,
  });

  /// The school's weekly days off, from `disabled_weekdays` ([5, 7] for a
  /// school closed Friday and Sunday) or, failing that, from the days
  /// `weekly_holidays` marks disabled. The two say the same thing.
  ///
  /// Sent neither way — an older server — the Egyptian weekend stands in,
  /// as the app assumed before the school could set it. An empty list is
  /// the school saying it has no weekly day off, and is kept.
  static Set<int> _weekendFrom(Map<String, dynamic> json) {
    final disabled = json['disabled_weekdays'];
    if (disabled is List) {
      return {
        for (final weekday in disabled)
          if (weekday is int) weekday,
      };
    }
    final weekly = json['weekly_holidays'];
    if (weekly is List) {
      return {
        for (final holiday in jsonObjects(weekly))
          if (holiday['disabled'] != false)
            if (holiday['weekday'] case final int weekday) weekday,
      };
    }
    return const {DateTime.friday, DateTime.saturday};
  }

  /// [month] is the one asked for, used if the response doesn't say.
  factory MonthAttendanceModel.fromJson(
    Map<String, dynamic> json, {
    required DateTime month,
  }) => MonthAttendanceModel(
    // "2026-10"
    month:
        DateTime.tryParse('${json['month']}-01') ??
        DateTime(month.year, month.month),
    counts: AttendanceCountsModel.fromJson(
      json['counts'] as Map<String, dynamic>? ?? const {},
    ),
    records: [
      for (final record in jsonObjects(json['records']))
        ?AttendanceRecordModel.fromJson(record),
    ],
    holidays: [
      for (final holiday in jsonObjects(json['holidays']))
        ?HolidayModel.fromJson(holiday),
    ],
    weekendWeekdays: _weekendFrom(json),
  );
}
