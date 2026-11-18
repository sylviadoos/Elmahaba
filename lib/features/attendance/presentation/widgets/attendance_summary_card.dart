import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/double_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/progress_ring.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/attendance_counts_entity.dart';

/// The month's attendance rate — late counts as attended — as a ring and
/// in words: "94.1% attendance · 16 of 17 school days".
class AttendanceSummaryCard extends StatelessWidget {
  const AttendanceSummaryCard({super.key, required this.counts});

  final AttendanceCountsEntity counts;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final total = counts.schoolDays;
    final attended = counts.attendedDays;
    final share = total > 0 ? attended / total : 0.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        spacing: 14.w,
        children: [
          ProgressRing(value: share, size: 58, holeSize: 44),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2.h,
              children: [
                Text.rich(
                  TextSpan(
                    // A dash, not 0%: no day attended, or none taken yet.
                    text: attended > 0 ? '${(share * 100).oneDecimal}%' : '-',
                    children: [
                      TextSpan(
                        text: ' ${l10n.attendanceWord}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 22.sp,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mahabbahRed,
                  ),
                ),
                Text(
                  l10n.attendedOfDays(attended, total),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 13.sp,
                    color: AppColors.slate,
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
