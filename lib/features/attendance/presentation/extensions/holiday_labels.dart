import 'package:flutter/widgets.dart';

import 'package:al_mahhaba_school/core/constants/app_constants.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/holiday_entity.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/month_attendance_entity.dart';

extension HolidayLabel on HolidayEntity {
  /// Its name in the app's language, else in whichever the school gave.
  String localName(BuildContext context) =>
      Localizations.localeOf(context).languageCode == AppConstants.arKey &&
          nameAr.isNotEmpty
      ? nameAr
      : (name.isNotEmpty ? name : nameAr);
}

extension SchoolDayOff on MonthAttendanceEntity {
  /// The holiday on [day]; null when it's none, or not in this month.
  HolidayEntity? holidayOn(DateTime day) => holidays
      .where(
        (holiday) =>
            holiday.date.year == day.year &&
            holiday.date.month == day.month &&
            holiday.date.day == day.day,
      )
      .firstOrNull;

  /// Whether [day], in this month, is one of the school's weekly days off.
  bool isWeekendOn(DateTime day) =>
      day.year == month.year &&
      day.month == month.month &&
      weekendWeekdays.contains(day.weekday);
}
