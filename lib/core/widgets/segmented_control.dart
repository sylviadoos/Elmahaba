import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

class SegmentOption {
  const SegmentOption(this.label, {this.enabled = true, this.fontFamily});

  final String label;
  final bool enabled;

  /// e.g. Cairo for an Arabic label in an English screen.
  final String? fontFamily;
}

/// Grey pill track with a white "selected" segment (Term 1 / Term 2,
/// English / عربي). With [expand] the segments share the full width.
class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.expand = true,
    this.height = 40,
    this.padding = 4,
    this.gap = 4,
    this.outerRadius = 14,
    this.innerRadius = 10,
    this.fontSize = 14,
  });

  final List<SegmentOption> options;
  final int selected;
  final ValueChanged<int> onSelected;
  final bool expand;

  /// Design values, in pixels.
  final double height;
  final double padding;
  final double gap;
  final double outerRadius;
  final double innerRadius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(outerRadius.r),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        spacing: gap.w,
        children: [
          for (final (index, option) in options.indexed)
            if (expand)
              Expanded(child: _segment(context, index, option))
            else
              _segment(context, index, option),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, int index, SegmentOption option) {
    final isSelected = index == selected;
    final radius = BorderRadius.circular(innerRadius.r);

    return Semantics(
      selected: isSelected,
      button: true,
      enabled: option.enabled,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: radius,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.08),
                    offset: Offset(0, 2.h),
                    blurRadius: 8.r,
                  ),
                ]
              : null,
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: option.enabled && !isSelected ? () => onSelected(index) : null,
          child: Container(
            height: height.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            alignment: Alignment.center,
            child: Text(
              option.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                fontSize: fontSize.sp,
                height: 1.2,
                fontWeight: FontWeight.w600,
                fontFamily: option.fontFamily,
                color: isSelected ? AppColors.mahabbahRed : AppColors.slate,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
