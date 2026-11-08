import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/widgets/equal_height_grid.dart';
import 'package:al_mahhaba_school/core/widgets/skeleton.dart';

/// Home's shape while the dashboard loads: the today banner and four cards.
class HomeDashboardSkeleton extends StatelessWidget {
  const HomeDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10.h,
        children: [
          SkeletonBar(width: 64.w, height: 10.h),
          SkeletonBar(width: 76.w, height: 22.h),
          SkeletonBar(height: 10.h),
        ],
      ),
    );

    return SkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14.h,
        children: [
          Container(
            height: 62.h,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          EqualHeightGrid(
            columns: 2,
            spacing: 10.w,
            children: [card, card, card, card],
          ),
        ],
      ),
    );
  }
}
