import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// A total when paying in full, in its color: "TOTAL AMOUNT · 19,000".
class PayTotalTile extends StatelessWidget {
  const PayTotalTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  /// (English, Arabic).
  final (String, String) label;
  final String value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        spacing: 10.w,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.$1.toUpperCase(),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: color,
                  ),
                ),
                Text(
                  label.$2,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.slate,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 20.sp,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
