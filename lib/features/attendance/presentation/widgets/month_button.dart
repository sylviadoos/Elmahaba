import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// Previous / next month arrow on the calendar; greyed out without
/// [onPressed].
class MonthButton extends StatelessWidget {
  const MonthButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final String icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surface,
        disabledBackgroundColor: AppColors.surface,
        fixedSize: Size.square(44.r),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      icon: AppSvgIcon(
        icon,
        size: 18.r,
        color: onPressed == null ? AppColors.mist : AppColors.ink,
        matchTextDirection: true,
      ),
    );
  }
}
