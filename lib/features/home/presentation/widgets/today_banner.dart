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

/// Today's date and the child's attendance today, in red when absent.
/// Opens Attendance.
class TodayBanner extends StatelessWidget {
  const TodayBanner({super.key, required this.status});

  /// e.g. "present"; null until today's attendance is taken.
  final String? status;

  static String _label(AppLocalizations l10n, String? status) =>
      switch (status) {
        null => l10n.attendanceNotTaken,
        'present' => l10n.present,
        'absent' => l10n.absent,
        'late' => l10n.late,
        // TODO: name the other statuses once the API lists them.
        final other => other,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final absent = status == 'absent';
    final foreground = absent ? AppColors.white : AppColors.ink;
    final date = DateFormat(
      'EEEE, MMM d',
      Localizations.localeOf(context).toString(),
    ).format(DateTime.now());

    return Material(
      color: absent ? AppColors.mahabbahRed : AppColors.blush,
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
                      _label(l10n, status),
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
