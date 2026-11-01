import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';

/// Centered icon and text for a page's empty, error and done states.
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    this.iconBackground = AppColors.blush,
    this.iconColor = AppColors.mahabbahRed,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String? subtitle;

  /// e.g. a "Try again" button.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final subtitle = this.subtitle;
    final action = this.action;

    return Padding(
      padding: EdgeInsets.only(top: 56.h),
      child: Column(
        children: [
          IconBox(
            icon,
            size: 64.r,
            iconSize: 28.r,
            circle: true,
            background: iconBackground,
            color: iconColor,
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 18.sp,
              color: AppColors.ink,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 6.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: AppColors.slate,
              ),
            ),
          ],
          if (action != null) ...[SizedBox(height: 20.h), action],
        ],
      ),
    );
  }
}
