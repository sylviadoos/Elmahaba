import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// An outlined card under a grey title strip, e.g. "DETAILS".
class ComplaintSection extends StatelessWidget {
  const ComplaintSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      // Drawn over the title strip, so its corners stay outlined.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: const BorderSide(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: const BoxDecoration(
              color: AppColors.paleSurface,
              border: Border(bottom: BorderSide(color: AppColors.hairline)),
            ),
            child: Semantics(
              header: true,
              child: Text(
                title.toUpperCase(),
                style: context.textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  height: 16 / 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.slate,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
