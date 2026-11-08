import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/widgets/skeleton.dart';

/// Results' shape while the result loads: the title card, the final result
/// and three subjects.
class ResultsSkeleton extends StatelessWidget {
  const ResultsSkeleton({super.key});

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
          block(92, 18),
          block(128, 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10.h,
            children: [
              SkeletonBar(width: 110.w, height: 16.h),
              block(84, 18),
              block(84, 18),
              block(84, 18),
            ],
          ),
        ],
      ),
    );
  }
}
