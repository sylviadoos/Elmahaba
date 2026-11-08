import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// A fees card: a grey strip with an icon and the [title] in English
/// (capitals) over Arabic, then [child]. No shadow and no clip, so it
/// scrolls smoothly: the strip rounds its own corners.
class StatementCard extends StatelessWidget {
  const StatementCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  final String icon;

  /// (English, Arabic).
  final (String, String) title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final radius = 20.r;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.paleSurface,
              // Inside the card's 1 px outline.
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(radius - 1),
              ),
              border: const Border(
                bottom: BorderSide(color: AppColors.hairline),
              ),
            ),
            child: Row(
              spacing: 12.w,
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.blush,
                    shape: BoxShape.circle,
                  ),
                  child: AppSvgIcon(
                    icon,
                    size: 16.r,
                    color: AppColors.mahabbahRed,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.$1.toUpperCase(),
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.slate,
                        ),
                      ),
                      Text(
                        title.$2,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.slate,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}
