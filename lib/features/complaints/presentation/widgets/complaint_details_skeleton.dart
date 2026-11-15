import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/widgets/skeleton.dart';

/// A complaint's shape while it loads: its sections.
class ComplaintDetailsSkeleton extends StatelessWidget {
  const ComplaintDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16.h,
        children: [
          for (final height in const [208.0, 120.0, 112.0])
            Container(
              height: height.h,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),
        ],
      ),
    );
  }
}
