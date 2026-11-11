import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// Round, translucent white icon button on a red header.
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.showDot = false,
  });

  final String icon;
  final String tooltip;
  final VoidCallback onPressed;

  /// A dot over the icon: there is something new behind it.
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.white.withValues(alpha: 0.16),
        fixedSize: Size.square(44.r),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: AppSvgIcon(icon, size: 20.r, color: AppColors.white),
    );
    if (!showDot) return button;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        // On the header's red, so it's ringed in white like the nav bar's.
        PositionedDirectional(
          top: 2.h,
          end: 2.w,
          child: Container(
            width: 12.r,
            height: 12.r,
            decoration: const ShapeDecoration(
              color: AppColors.actionRed,
              shape: CircleBorder(
                side: BorderSide(color: AppColors.white, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
