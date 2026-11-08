import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// Why the school didn't take the complaint, in a pale red box over the
/// form.
class ComplaintErrorAlert extends StatelessWidget {
  const ComplaintErrorAlert(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.errorBg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.errorBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10.w,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: AppSvgIcon(
                AppIcons.alertCircle,
                size: 18.r,
                color: AppColors.mahabbahRed,
              ),
            ),
            Expanded(
              child: Text(
                message,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.mahabbahRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
