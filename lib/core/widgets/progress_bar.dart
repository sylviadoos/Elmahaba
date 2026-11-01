import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';

/// Thin rounded bar filled to [value] (0–1) in red, from the start side.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.trackColor = AppColors.surface,
  });

  final double value;

  /// Design pixels.
  final double height;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular((height / 2).r);

    return Container(
      height: height.h,
      decoration: BoxDecoration(color: trackColor, borderRadius: radius),
      alignment: AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0, 1),
        heightFactor: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.actionRed,
            borderRadius: radius,
          ),
        ),
      ),
    );
  }
}
