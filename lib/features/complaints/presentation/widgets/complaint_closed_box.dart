import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// In place of a reply once the complaint is closed: says so, and offers a
/// new one ([onNewComplaint]).
class ComplaintClosedBox extends StatelessWidget {
  const ComplaintClosedBox({super.key, required this.onNewComplaint});

  final VoidCallback onNewComplaint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12.h,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10.w,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: AppSvgIcon(
                  AppIcons.lock,
                  size: 18.r,
                  color: AppColors.slate,
                ),
              ),
              Expanded(
                child: Text(
                  l10n.complaintClosedNote,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.ink),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onNewComplaint,
            style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(50.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              textStyle: textTheme.labelLarge?.copyWith(fontSize: 15.sp),
            ),
            child: Text(l10n.newComplaint),
          ),
        ],
      ),
    );
  }
}
