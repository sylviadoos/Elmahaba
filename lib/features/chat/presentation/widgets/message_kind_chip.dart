import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// "General" (red) or "Private" (blush) pill with its icon.
class MessageKindChip extends StatelessWidget {
  const MessageKindChip({
    super.key,
    required this.isGeneral,
    required this.label,
    this.bold = false,
  });

  final bool isGeneral;
  final String label;

  /// Message chips are bolder and wider than the legend chips.
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final foreground = isGeneral ? AppColors.white : AppColors.mahabbahRed;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (bold ? 12 : 10).w,
        vertical: 5.h,
      ),
      decoration: ShapeDecoration(
        color: isGeneral ? AppColors.mahabbahRed : AppColors.blush,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: (bold ? 6 : 5).w,
        children: [
          AppSvgIcon(
            isGeneral ? AppIcons.megaphoneGeneral : AppIcons.lockPrivate,
            size: 12.r,
            color: foreground,
          ),
          Flexible(
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: 12.sp,
                height: 1.3,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
