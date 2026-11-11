import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/attendance/data/models/month_attendance_model.dart';

/// A school closed Fridays and Sundays, as the new response says it.
const _weekly = {
  'weekly_holidays': [
    {
      'day': 'friday',
      'weekday': 5,
      'name': 'Friday',
      'name_ar': 'الجمعة',
      'disabled': true,
    },
    {
      'day': 'sunday',
      'weekday': 7,
      'name': 'Sunday',
      'name_ar': 'الأحد',
      'disabled': true,
    },
  ],
  'disabled_weekdays': [5, 7],
};

void main() {
  final october = DateTime(2026, 10);

  Set<int> weekendOf(Map<String, dynamic> json) =>
      MonthAttendanceModel.fromJson({
        'month': '2026-10',
        ...json,
      }, month: october).weekendWeekdays;

  test('the school says which days it is closed', () {
    expect(weekendOf(_weekly), {DateTime.friday, DateTime.sunday});
  });

  test('without disabled_weekdays, the weekly holidays say it', () {
    final json = Map<String, dynamic>.from(_weekly)
      ..remove('disabled_weekdays');

    expect(weekendOf(json), {DateTime.friday, DateTime.sunday});
  });

  test('a weekly holiday left on is not a day off', () {
    expect(
      weekendOf({
        'weekly_holidays': [
          {'weekday': 5, 'disabled': true},
          {'weekday': 7, 'disabled': false},
        ],
      }),
      {DateTime.friday},
    );
  });

  test('no weekly day off at all is kept, not filled in', () {
    expect(weekendOf({'disabled_weekdays': <int>[]}), isEmpty);
  });

  test('a server that says nothing: the Egyptian weekend, as before', () {
    expect(weekendOf(const {}), {DateTime.friday, DateTime.saturday});
  });

  test('the rest of the month is read as it was', () {
    final month = MonthAttendanceModel.fromJson({
      'month': '2026-10',
      'counts': {'present': 15, 'absent': 1, 'late': 1},
      'records': [
        {'date': '2026-10-26', 'status': 'absent', 'reason': 'sick'},
      ],
      'holidays': [
        {'date': '2026-10-06', 'name': '6 october', 'name_ar': '6 اكتوبر'},
      ],
      ..._weekly,
    }, month: october);

    expect(month.month, october);
    // The late day counts as present, as before.
    expect(month.counts.presentDays, 16);
    expect(month.records.single.date, DateTime(2026, 10, 26));
    expect(month.holidays.single.nameAr, '6 اكتوبر');
  });
}
