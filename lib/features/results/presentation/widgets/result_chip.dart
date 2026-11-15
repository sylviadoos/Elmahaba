import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// Small pill on a result: a grade ("Excellent"), an assessment
/// ("Final: اجتاز") or an activity's status. [large] is the activities'.
class ResultChip extends StatelessWidget {
  const ResultChip(
    this.label, {
    super.key,
    this.color = AppColors.ink,
    this.background = AppColors.surface,
    this.bold = false,
    this.large = false,
  });

  final String label;
  final Color color;
  final Color background;
  final bool bold;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: large
          ? EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h)
          : EdgeInsets.symmetric(horizontal: 9.w, vertical: 2.h),
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          fontSize: (large ? 12 : 11).sp,
          height: 1.4,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
