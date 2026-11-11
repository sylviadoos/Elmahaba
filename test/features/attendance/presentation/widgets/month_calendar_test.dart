import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/features/attendance/domain/entities/attendance_counts_entity.dart';
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
  MonthAttendanceEntity month(Set<int> weekendWeekdays) =>
      MonthAttendanceEntity(
        month: _october,
        counts: const AttendanceCountsEntity(
          presentDays: 0,
          absentDays: 0,
          excusedDays: 0,
        ),
        records: const [],
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
    Set<int> weekendWeekdays,
  ) async {
    tester.usePhoneScreen();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: SingleChildScrollView(
              child: MonthCalendar(
                attendance: month(weekendWeekdays),
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
}
