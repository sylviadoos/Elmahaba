import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/features/attendance/domain/entities/attendance_counts_entity.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/attendance_record_entity.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/attendance_status.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/holiday_entity.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/month_attendance_entity.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/widgets/calendar_day_cell.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/widgets/month_calendar.dart';

import '../../../../helpers/test_app.dart';

final _october = DateTime(2026, 10);

/// The 6th, which the school lists as a holiday.
final _armedForcesDay = DateTime(2026, 10, 6);

void main() {
  /// October 2026 for a school closed on [weekendWeekdays].
  MonthAttendanceEntity month(
    Set<int> weekendWeekdays, {
    List<AttendanceRecordEntity> records = const [],
  }) => MonthAttendanceEntity(
    month: _october,
    counts: const AttendanceCountsEntity(
      presentDays: 0,
      absentDays: 0,
      excusedDays: 0,
    ),
    records: records,
    holidays: [
      HolidayEntity(
        date: _armedForcesDay,
        name: '6 october',
        nameAr: '6 اكتوبر',
      ),
    ],
    weekendWeekdays: weekendWeekdays,
  );

  /// What the calendar shows for each day of the month, by day number.
  Future<Map<int, CalendarDay>> pumpCalendar(
    WidgetTester tester,
    Set<int> weekendWeekdays, {
    List<AttendanceRecordEntity> records = const [],
    Set<DateTime> excuseDates = const {},
  }) async {
    tester.usePhoneScreen();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: SingleChildScrollView(
              child: MonthCalendar(
                attendance: month(weekendWeekdays, records: records),
                excuseDates: excuseDates,
                onPrevious: () {},
                onNext: null,
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(TestApp(router: router));
    await tester.pumpAndSettle();

    // In order, the 1st onwards; the blanks before it aren't cells.
    final cells = tester.widgetList<CalendarDayCell>(
      find.byType(CalendarDayCell),
    );
    return {for (final (index, cell) in cells.indexed) index + 1: cell.day};
  }

  testWidgets('Fridays and Sundays off: those days are the weekend', (
    tester,
  ) async {
    final shown = await pumpCalendar(tester, {
      DateTime.friday,
      DateTime.sunday,
    });

    for (final MapEntry(key: day, value: kind) in shown.entries) {
      final date = DateTime(2026, 10, day);
      if (date == _armedForcesDay) continue;
      expect(kind, switch (date.weekday) {
        DateTime.friday || DateTime.sunday => CalendarDay.weekend,
        _ => CalendarDay.other,
      }, reason: '${date.weekday} of October $day');
    }
  });

  testWidgets('Fridays and Saturdays off: Sunday is a school day', (
    tester,
  ) async {
    final shown = await pumpCalendar(tester, {
      DateTime.friday,
      DateTime.saturday,
    });
    final firstSunday = DateTime(
      2026,
      10,
    ).add(Duration(days: (DateTime.sunday - DateTime(2026, 10).weekday) % 7));

    expect(shown[firstSunday.day], CalendarDay.other);
  });

  testWidgets('no weekly day off: no day is greyed as one', (tester) async {
    final shown = await pumpCalendar(tester, const {});

    expect(shown.values, isNot(contains(CalendarDay.weekend)));
  });

  testWidgets('a holiday on a day off still reads as the holiday', (
    tester,
  ) async {
    final shown = await pumpCalendar(tester, {_armedForcesDay.weekday});

    expect(shown[_armedForcesDay.day], CalendarDay.holiday);
  });

  testWidgets('an absence is red until an excuse is sent for it, then '
      'excused; a present day stays present', (tester) async {
    final excused = DateTime(2026, 10, 12);
    final unexcused = DateTime(2026, 10, 13);
    final present = DateTime(2026, 10, 14);

    final shown = await pumpCalendar(
      tester,
      const {},
      records: [
        AttendanceRecordEntity(date: excused, status: AttendanceStatus.absent),
        AttendanceRecordEntity(
          date: unexcused,
          status: AttendanceStatus.absent,
        ),
        AttendanceRecordEntity(date: present, status: AttendanceStatus.present),
      ],
      excuseDates: {excused, present},
    );

    expect(shown[12], CalendarDay.excused);
    expect(shown[13], CalendarDay.absent);
    expect(shown[14], CalendarDay.present);
  });

  testWidgets('a late day is shown late, not present', (tester) async {
    final late = DateTime(2026, 10, 15);

    final shown = await pumpCalendar(
      tester,
      const {},
      records: [
        AttendanceRecordEntity(date: late, status: AttendanceStatus.late),
      ],
    );

    expect(shown[15], CalendarDay.late);
  });
}
