import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// A total at the end of the statement, e.g. "Total amount · 19,000".
class StatementTotalRow extends StatelessWidget {
  const StatementTotalRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.background = AppColors.surface,
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
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
                  label.$1,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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
              fontSize: 18.sp,
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
