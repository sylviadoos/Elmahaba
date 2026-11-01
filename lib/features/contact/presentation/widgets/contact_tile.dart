import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';

/// A tappable phone number or email: icon, small label, value, chevron.
class ContactTile extends StatelessWidget {
  const ContactTile({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueSize = 15,
    this.valueIsLtr = true,
    required this.onTap,
  });

  final String icon;
  final Color iconBackground;
  final Color iconColor;
  final String label;
  final String value;
  final double valueSize;

  /// Numbers and emails read left to right in Arabic too; set false for
  /// translated text.
  final bool valueIsLtr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Material(
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            spacing: 14.w,
            children: [
              IconBox(
                icon,
                size: 42.r,
                iconSize: 19.r,
                radius: 14.r,
                background: iconBackground,
                color: iconColor,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.slate,
                      ),
                    ),
                    // Shrinks a long email to fit rather than breaking it.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        value,
                        textDirection: valueIsLtr ? TextDirection.ltr : null,
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: valueSize.sp,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSvgIcon(
                AppIcons.chevronRight,
                size: 18.r,
                color: AppColors.mist,
                matchTextDirection: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
