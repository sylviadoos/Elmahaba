import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/widgets/skeleton.dart';

/// Complaints' shape while the complaints load: a few cards.
class ComplaintsSkeleton extends StatelessWidget {
  const ComplaintsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10.h,
        children: [
          for (var i = 0; i < 4; i++)
            Container(
              height: 96.h,
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
