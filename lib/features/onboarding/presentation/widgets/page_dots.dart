import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_constants.dart';

/// Page indicator: the current page is a long red pill, the others grey dots.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(width: 6.w),
          AnimatedContainer(
            duration: AppConstants.animationDuration,
            width: (i == current ? 24 : 6).r,
            height: 6.r,
            decoration: BoxDecoration(
              color: i == current ? AppColors.actionRed : AppColors.line,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
        ],
      ],
    );
  }
}
