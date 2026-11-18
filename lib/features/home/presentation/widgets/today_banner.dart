import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';

/// Today's date and the child's attendance today, in red when absent. With
/// nothing recorded on a holiday or a weekly day off, that instead — in
/// gold for a holiday, as on the calendar — so it doesn't read as missing.
/// Opens Attendance.
class TodayBanner extends StatelessWidget {
  const TodayBanner({
    super.key,
    required this.status,
    this.holidayName,
    this.isWeekend = false,
  });

  /// e.g. "present"; null until today's attendance is taken.
  final String? status;

  /// Today's holiday, by name ("6 October"; empty when the school gave
  /// none); null when today isn't one.
  final String? holidayName;

  /// Today is one of the school's weekly days off.
  final bool isWeekend;

  String _label(AppLocalizations l10n) {
    final holiday = holidayName;
    return switch (status) {
      null when holiday != null =>
        holiday.isEmpty
            ? l10n.officialHoliday
            : '${l10n.officialHoliday} · $holiday',
      null when isWeekend => l10n.friSatOff,
      null => l10n.attendanceNotTaken,
      'present' => l10n.present,
      'late' => l10n.late,
      'absent' => l10n.absent,
      // TODO: name the other statuses once the API lists them.
      final other => other,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final absent = status == 'absent';
    final holiday = status == null && holidayName != null;
    final (background, foreground) = absent
        ? (AppColors.mahabbahRed, AppColors.white)
        : holiday
        ? (AppColors.gold, AppColors.goldText)
        : (AppColors.blush, AppColors.ink);
    final date = DateFormat(
      'EEEE, MMM d',
      Localizations.localeOf(context).toString(),
    ).format(DateTime.now());

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(AppRoutes.attendance),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            spacing: 12.w,
            children: [
              IconBox(
                AppIcons.calendarToday,
                size: 38.r,
                iconSize: 18.r,
                radius: 12.r,
                background: AppColors.white.withValues(alpha: 0.7),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.today} · $date',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: foreground.withValues(alpha: 0.85),
                      ),
                    ),
                    Text(
                      _label(l10n),
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 15.sp,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
