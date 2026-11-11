import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// How a day looks on the calendar; [other] for a day not taken (yet).
enum CalendarDay { present, absent, excused, holiday, weekend, other }

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
      CalendarDay.present => (
        AppColors.successBg,
        AppColors.success,
        FontWeight.w700,
      ),
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

    return Container(
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
  }
}
