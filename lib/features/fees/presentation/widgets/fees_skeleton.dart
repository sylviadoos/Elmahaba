import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/widgets/skeleton.dart';

/// Fees' shape while the statement loads: the student card, the statement
/// and the pay button.
class FeesSkeleton extends StatelessWidget {
  const FeesSkeleton({super.key});

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
        children: [block(250, 20), block(420, 20), block(56, 16)],
      ),
    );
  }
}
