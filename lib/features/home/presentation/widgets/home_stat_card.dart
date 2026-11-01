import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// Home summary tile: title and icon, a big number, a short line and an
/// optional [footer]. [highlighted] is the solid red version (School chat).
class HomeStatCard extends StatelessWidget {
  const HomeStatCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.subtitle,
    this.footer,
    this.highlighted = false,
    this.onTap,
  });

  final String title;
  final String icon;
  final String value;
  final String subtitle;
  final Widget? footer;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final softText = highlighted
        ? AppColors.white.withValues(alpha: 0.88)
        : AppColors.slate;

    return Material(
      color: highlighted ? AppColors.mahabbahRed : AppColors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: highlighted
            ? BorderSide.none
            : const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6.h,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: softText,
                      ),
                    ),
                  ),
                  AppSvgIcon(
                    icon,
                    size: 16.r,
                    color: highlighted
                        ? AppColors.white
                        : AppColors.mahabbahRed,
                  ),
                ],
              ),
              Text(
                value,
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 24.sp,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: highlighted ? AppColors.white : AppColors.mahabbahRed,
                ),
              ),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  height: 16 / 12,
                  color: softText,
                ),
              ),
              ?footer,
            ],
          ),
        ),
      ),
    );
  }
}
