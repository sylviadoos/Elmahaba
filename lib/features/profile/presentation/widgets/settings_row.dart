import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';

/// Settings line: icon tile, label and a [trailing] control (a chevron by
/// default).
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  final String icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          spacing: 12.w,
          children: [
            IconBox(
              icon,
              size: 38.r,
              iconSize: 18.r,
              radius: 12.r,
              background: AppColors.surface,
            ),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontSize: 15.sp,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ??
                AppSvgIcon(
                  AppIcons.chevronRight,
                  size: 18.r,
                  color: AppColors.mist,
                  matchTextDirection: true,
                ),
          ],
        ),
      ),
    );
  }
}
