import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/widgets/equal_height_grid.dart';
import 'package:al_mahhaba_school/core/widgets/skeleton.dart';

/// Attendance's shape while the month loads: the rate, the four counts,
/// the calendar and two days.
class AttendanceSkeleton extends StatelessWidget {
  const AttendanceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget block(double height, double radius) => Container(
      height: height.h,
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );

    return SkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 18.h,
        children: [
          block(86, 18),
          EqualHeightGrid(
            columns: 4,
            spacing: 10.w,
            children: [for (var i = 0; i < 4; i++) block(64, 16)],
          ),
          block(380, 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10.h,
            children: [
              SkeletonBar(width: 110.w, height: 16.h),
              block(70, 16),
              block(70, 16),
            ],
          ),
        ],
      ),
    );
  }
}
