import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/double_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/progress_ring.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';

/// The final result out of the counted subjects' maximum — as a ring and in
/// numbers — the school's word for it when there's one (a term's, "ناجح"),
/// the attendance, and the rank in the class when there's one (a month's).
class FinalResultCard extends StatelessWidget {
  const FinalResultCard({super.key, required this.result});

  final ResultDetailsEntity result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final finalResult = result.finalResult;
    final finalMax = result.finalMax;
    final share = finalResult != null && finalMax > 0
        ? (finalResult / finalMax).clamp(0.0, 1.0)
        : 0.0;
    final attendance = result.attendancePercentage;
    final rank = result.rank;

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        spacing: 16.w,
        children: [
          ProgressRing(
            value: share,
            size: 92,
            holeSize: 72,
            child: Text(
              // A dash, not 0%: no mark yet, or none earned.
              share > 0 ? '${(share * 100).oneDecimal}%' : '-',
              textDirection: TextDirection.ltr,
              style: textTheme.titleLarge?.copyWith(
                fontSize: 19.sp,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4.h,
              children: [
                Text(
                  l10n.finalResult,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 13.sp,
                    color: AppColors.slate,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: finalResult?.oneDecimal ?? '—',
                    children: [
                      TextSpan(
                        text: ' / ${finalMax.oneDecimal}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate,
                        ),
                      ),
                    ],
                  ),
                  textDirection: TextDirection.ltr,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 24.sp,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mahabbahRed,
                  ),
                ),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: [
                    if (result.verdict case final verdict?)
                      _Pill(icon: AppIcons.check, label: verdict),
                    _Pill(
                      icon: AppIcons.calendarPresent,
                      label: l10n.attendancePercent(
                        // A dash, not 0%, as on Attendance.
                        attendance == null || attendance <= 0
                            ? '-'
                            : '${attendance.oneDecimal}%',
                      ),
                    ),
                    if (rank != null)
                      _Pill(
                        icon: AppIcons.navResults,
                        label: l10n.classRank(rank),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// White pill under the final result: an icon and a short fact.
class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: const ShapeDecoration(
        color: AppColors.white,
        shape: StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6.w,
        children: [
          AppSvgIcon(icon, size: 13.r, color: AppColors.mahabbahRed),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
