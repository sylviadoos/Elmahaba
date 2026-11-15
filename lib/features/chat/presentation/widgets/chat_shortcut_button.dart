import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// A page a tap away in the chat's red header: its icon in a see-through
/// square, with a gold dot in the corner while there's news about it.
class ChatShortcutButton extends StatelessWidget {
  const ChatShortcutButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.hasNews,
    required this.onTap,
  });

  final String icon;

  /// The page's name.
  final String tooltip;
  final bool hasNews;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dot = 8.r;

    return Stack(
      children: [
        IconButton(
          onPressed: onTap,
          tooltip: tooltip,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.white.withValues(alpha: 0.16),
            fixedSize: Size.square(40.r),
            minimumSize: Size.square(40.r),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          icon: AppSvgIcon(icon, size: 20.r, color: AppColors.white),
        ),
        if (hasNews)
          // A 2 px ring of the header's red around it.
          PositionedDirectional(
            top: 6.r - 2,
            end: 6.r - 2,
            child: IgnorePointer(
              child: Container(
                width: dot + 4,
                height: dot + 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold,
                  border: Border.all(color: AppColors.mahabbahRed, width: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
