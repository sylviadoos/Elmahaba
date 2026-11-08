import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// One option of a choice group: a round chip, filled red when picked.
class ComplaintChoiceChip extends StatelessWidget {
  const ComplaintChoiceChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (background, border, foreground) = isSelected
        ? (AppColors.mahabbahRed, AppColors.mahabbahRed, AppColors.white)
        : (AppColors.white, AppColors.line, AppColors.ink);

    return Semantics(
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: background,
        shape: StadiumBorder(side: BorderSide(color: border, width: 1.5)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            // widthFactor keeps the chip as wide as its label inside a Wrap.
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  height: 1.2,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: foreground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
