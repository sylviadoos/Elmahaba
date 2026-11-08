import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_due_status.dart';

/// When a homework is due ([label]), colored by [status]: blue ahead,
/// amber today, grey once past or with no date.
class HomeworkDueBadge extends StatelessWidget {
  const HomeworkDueBadge({
    super.key,
    required this.status,
    required this.label,
  });

  final HomeworkDueStatus status;

  /// e.g. "Due Wed 11 Nov".
  final String label;

  @override
  Widget build(BuildContext context) {
    final (color, background) = switch (status) {
      HomeworkDueStatus.upcoming => (AppColors.info, AppColors.infoBg),
      HomeworkDueStatus.dueToday => (AppColors.warning, AppColors.warningBg),
      HomeworkDueStatus.past ||
      HomeworkDueStatus.noDueDate ||
      HomeworkDueStatus.unknown => (AppColors.slate, AppColors.surface),
    };

    // A pill on one line; a long date (Arabic, big text, a small phone)
    // wraps inside the card rather than running out of it.
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6.w,
        children: [
          AppSvgIcon(AppIcons.calendarToday, size: 14.r, color: color),
          Flexible(
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: 12.sp,
                height: 16 / 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
