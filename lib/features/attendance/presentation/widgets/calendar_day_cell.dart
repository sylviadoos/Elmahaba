import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/dashed_border.dart';

/// How a day looks on the calendar. A plain "present" isn't listed by the
/// API, so it's an [other] day, like one not taken yet.
enum CalendarDay { absent, late, excused, holiday, weekend, other }

/// One day on the month calendar, colored by what it was.
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({super.key, required this.label, required this.day});

  final String label;
  final CalendarDay day;

  @override
  Widget build(BuildContext context) {
    final (background, color, weight) = switch (day) {
      CalendarDay.absent => (
        AppColors.mahabbahRed,
        AppColors.white,
        FontWeight.w700,
      ),
      CalendarDay.late => (null, AppColors.mahabbahRed, FontWeight.w600),
      CalendarDay.excused => (
        AppColors.infoBg,
        AppColors.info,
        FontWeight.w600,
      ),
      CalendarDay.holiday => (
        AppColors.gold,
        AppColors.goldText,
        FontWeight.w700,
      ),
      CalendarDay.weekend => (null, AppColors.mist, FontWeight.w400),
      CalendarDay.other => (null, AppColors.ink, FontWeight.w500),
    };
    final radius = 10.r;

    final cell = Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        label,
        style: context.textTheme.bodyMedium?.copyWith(
          height: 1,
          fontWeight: weight,
          color: color,
        ),
      ),
    );

    return day == CalendarDay.late
        ? DashedBorder(radius: radius, child: cell)
        : cell;
  }
}
