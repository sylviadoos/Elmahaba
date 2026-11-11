import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/attendance_status.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/month_attendance_entity.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/widgets/calendar_day_cell.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/widgets/calendar_legend.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/widgets/month_switcher.dart';

/// The month's grid (weeks start on Sunday): each day colored by what it
/// was, the month arrows and a legend. [onNext] is null on the latest month.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.attendance,
    required this.onPrevious,
    required this.onNext,
  });

  final MonthAttendanceEntity attendance;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  /// Holidays first, then the recorded days, then the school's weekly days
  /// off.
  CalendarDay _dayOf(DateTime date) {
    bool sameDay(DateTime other) =>
        other.year == date.year &&
        other.month == date.month &&
        other.day == date.day;

    if (attendance.holidays.any((holiday) => sameDay(holiday.date))) {
      return CalendarDay.holiday;
    }
    final record = attendance.records.where((r) => sameDay(r.date));
    switch (record.firstOrNull?.status) {
      case AttendanceStatus.present:
        return CalendarDay.present;
      case AttendanceStatus.absent:
        return CalendarDay.absent;
      case AttendanceStatus.excused:
        return CalendarDay.excused;
      case AttendanceStatus.unknown || null:
        break;
    }
    return attendance.weekendWeekdays.contains(date.weekday)
        ? CalendarDay.weekend
        : CalendarDay.other;
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final month = attendance.month;
    // Sunday-first column of the 1st (DateTime.weekday is 1 = Monday).
    final leadingBlanks = DateTime(month.year, month.month).weekday % 7;
    final cells = <Widget>[
      for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
      for (
        var day = 1;
        day <= DateUtils.getDaysInMonth(month.year, month.month);
        day++
      )
        CalendarDayCell(
          label: DateFormat.d(
            locale,
          ).format(DateTime(month.year, month.month, day)),
          day: _dayOf(DateTime(month.year, month.month, day)),
        ),
    ];
    // A Sunday, so the header reads Sun … Sat.
    final aSunday = DateTime(2026, 10, 4);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12.h,
        children: [
          MonthSwitcher(month: month, onPrevious: onPrevious, onNext: onNext),
          _WeekRow(
            children: [
              for (var i = 0; i < 7; i++)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    DateFormat.E(locale).format(aSunday.add(Duration(days: i))),
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate,
                    ),
                  ),
                ),
            ],
          ),
          Column(
            spacing: 4.h,
            children: [
              for (var start = 0; start < cells.length; start += 7)
                _WeekRow(
                  children: [
                    for (var i = start; i < start + 7; i++)
                      i < cells.length
                          ? SizedBox(height: 38.h, child: cells[i])
                          : const SizedBox.shrink(),
                  ],
                ),
            ],
          ),
          const CalendarLegend(),
        ],
      ),
    );
  }
}

/// Seven equal columns.
class _WeekRow extends StatelessWidget {
  const _WeekRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4.w,
      children: [for (final child in children) Expanded(child: child)],
    );
  }
}
