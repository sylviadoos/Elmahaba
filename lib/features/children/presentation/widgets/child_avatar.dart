import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// A child's initial in a colored circle. Each child keeps its colors by
/// its place among the parent's children ([index]).
class ChildAvatar extends StatelessWidget {
  const ChildAvatar({
    super.key,
    required this.name,
    required this.index,
    required this.size,
    this.fontSize,
  });

  final String name;
  final int index;
  final double size;

  /// The initial's; 16 by default.
  final double? fontSize;

  /// Background and initial, in turn.
  static const List<(Color, Color)> _colors = [
    (AppColors.blush, AppColors.mahabbahRed),
    (AppColors.infoBg, AppColors.info),
    (AppColors.successBg, AppColors.success),
    (AppColors.warningBg, AppColors.warning),
    (AppColors.gold, AppColors.goldText),
  ];

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _colors[index % _colors.length];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: background),
      child: Text(
        name.isEmpty ? '' : name.characters.first,
        style: context.textTheme.bodyLarge?.copyWith(
          fontSize: fontSize ?? 16.sp,
          height: 1,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
