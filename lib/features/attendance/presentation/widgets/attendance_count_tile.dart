import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/dashed_border.dart';

/// How a count tile looks, matching the calendar: present, absent, late
/// (a dashed red outline), excused.
enum CountTileStyle { present, solid, dashed, info }

/// A month's count of one kind of day, e.g. "15 · Present".
class AttendanceCountTile extends StatelessWidget {
  const AttendanceCountTile({
    super.key,
    required this.count,
    required this.label,
    required this.style,
  });

  final int count;
  final String label;
  final CountTileStyle style;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final radius = 16.r;
    final (background, numberColor, labelColor) = switch (style) {
      CountTileStyle.present => (
        AppColors.successBg,
        AppColors.success,
        AppColors.slate,
      ),
      CountTileStyle.solid => (
        AppColors.mahabbahRed,
        AppColors.white,
        AppColors.white.withValues(alpha: 0.88),
      ),
      CountTileStyle.dashed => (null, AppColors.mahabbahRed, AppColors.slate),
      CountTileStyle.info => (
        AppColors.infoBg,
        AppColors.info,
        AppColors.slate,
      ),
    };

    final tile = Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        spacing: 2.h,
        children: [
          Text(
            '$count',
            style: textTheme.titleLarge?.copyWith(
              fontSize: 22.sp,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: numberColor,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12.sp,
                color: labelColor,
              ),
            ),
          ),
        ],
      ),
    );

    return style == CountTileStyle.dashed
        ? DashedBorder(radius: radius, child: tile)
        : tile;
  }
}
