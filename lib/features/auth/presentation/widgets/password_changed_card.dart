import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// A check mark, "Password changed" ([title]), what comes next ([message])
/// and a button on ([actionLabel], [onAction]).
class PasswordChangedCard extends StatelessWidget {
  const PasswordChangedCard({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12.h,
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.mahabbahRed,
              shape: BoxShape.circle,
            ),
            child: AppSvgIcon(
              AppIcons.check,
              size: 30.r,
              color: AppColors.white,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(fontSize: 20.sp),
          ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              height: 20 / 14,
              color: AppColors.slate,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(52.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                textStyle: textTheme.labelLarge?.copyWith(fontSize: 15.sp),
              ),
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}
