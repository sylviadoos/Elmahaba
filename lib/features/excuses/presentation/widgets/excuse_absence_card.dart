import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excusable_absence_entity.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/extensions/excuse_labels.dart';

/// The absence an excuse is for: its day, the reason the school has, and
/// the last day to send it.
class ExcuseAbsenceCard extends StatelessWidget {
  const ExcuseAbsenceCard({super.key, required this.absence});

  final ExcusableAbsenceEntity absence;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final reason = absence.absenceReason;
    final until = absence.submitUntil;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.blushPale,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.rose),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.w,
        children: [
          IconBox(
            AppIcons.navAttendance,
            size: 40.r,
            iconSize: 20.r,
            radius: 12.r,
            background: AppColors.white,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3.h,
              children: [
                Text(
                  l10n.excuseForAbsence(absence.date.excuseDayLabel(context)),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                if (reason != null)
                  Text(
                    l10n.reasonIs(reason),
                    textDirection: reason.textDirection,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 13.sp,
                      color: AppColors.slate,
                    ),
                  ),
                if (until != null)
                  Text(
                    l10n.excuseSubmitUntil(until.excuseDayLabel(context)),
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mahabbahRed,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
