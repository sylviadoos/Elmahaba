import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// A filter on the red header: white when picked, outlined otherwise.
class StatusFilterChip extends StatelessWidget {
  const StatusFilterChip({
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
    return Semantics(
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: isSelected ? AppColors.white : Colors.transparent,
        shape: StadiumBorder(
          side: isSelected
              ? BorderSide.none
              : BorderSide(color: AppColors.white.withValues(alpha: 0.35)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 38.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            // widthFactor keeps the chip as wide as its label inside a Wrap.
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  fontSize: 13.sp,
                  height: 1.2,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.mahabbahRed : AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
