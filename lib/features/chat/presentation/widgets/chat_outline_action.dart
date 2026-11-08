import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// Full-width red outline button on a school item, e.g. "View attendance".
class ChatOutlineAction extends StatelessWidget {
  const ChatOutlineAction({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.actionRed,
        minimumSize: Size.fromHeight(44.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        side: const BorderSide(color: AppColors.actionRed, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: context.textTheme.labelLarge?.copyWith(fontSize: 14.sp),
      ),
      child: Text(label),
    );
  }
}
