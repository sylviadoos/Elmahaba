import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/widgets/skeleton.dart';

/// [LinkedChildCard]'s shape while the children load.
class LinkedChildCardSkeleton extends StatelessWidget {
  const LinkedChildCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          spacing: 12.w,
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: const BoxDecoration(
                color: AppColors.line,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8.h,
                children: [
                  SkeletonBar(width: 150.w, height: 14.h),
                  SkeletonBar(width: 110.w, height: 10.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
