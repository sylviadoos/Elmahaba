import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// "Your complaint has been submitted.": its [reference] and [status], and
/// on to it or back to the complaints.
class ComplaintSentCard extends StatelessWidget {
  const ComplaintSentCard({
    super.key,
    required this.reference,
    required this.status,
    required this.onViewComplaint,
    required this.onBackToComplaints,
  });

  /// e.g. "CMP-2026-00012".
  final String reference;

  /// e.g. "Submitted".
  final String status;
  final VoidCallback onViewComplaint;
  final VoidCallback onBackToComplaints;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final buttonText = textTheme.labelLarge?.copyWith(
      fontSize: 15.sp,
      fontWeight: FontWeight.w600,
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14.r),
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10.h,
        children: [
          Center(
            child: Container(
              width: 60.r,
              height: 60.r,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.mahabbahRed,
                shape: BoxShape.circle,
              ),
              child: AppSvgIcon(
                AppIcons.check,
                size: 28.r,
                color: AppColors.white,
              ),
            ),
          ),
          Text(
            l10n.complaintSubmitted,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(fontSize: 19.sp),
          ),
          Text.rich(
            TextSpan(
              text: '${l10n.complaintReference} ',
              children: [
                TextSpan(
                  text: reference,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                TextSpan(text: ' · $status'),
              ],
            ),
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.slate),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: ElevatedButton(
              onPressed: onViewComplaint,
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(52.h),
                shape: buttonShape,
                textStyle: buttonText,
              ),
              child: Text(l10n.viewComplaint),
            ),
          ),
          OutlinedButton(
            onPressed: onBackToComplaints,
            style: OutlinedButton.styleFrom(
              minimumSize: Size.fromHeight(48.h),
              shape: buttonShape,
              foregroundColor: AppColors.actionRed,
              side: const BorderSide(color: AppColors.actionRed, width: 1.5),
              textStyle: buttonText,
            ),
            child: Text(l10n.backToComplaints),
          ),
        ],
      ),
    );
  }
}
