import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// White title and subtitle inside the red auth headers.
/// [subtitleBold] is appended to the subtitle in bold (e.g. a phone number).
class AuthHeaderTitle extends StatelessWidget {
  const AuthHeaderTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.subtitleBold,
  });

  final String title;
  final String subtitle;
  final String? subtitleBold;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6.h,
      children: [
        Text(
          title,
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.white,
            letterSpacing: 0,
          ),
        ),
        Text.rich(
          TextSpan(
            text: subtitle,
            children: [
              if (subtitleBold != null)
                TextSpan(
                  text: subtitleBold,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
            ],
          ),
          style: textTheme.bodyLarge?.copyWith(
            fontSize: 15.sp,
            height: 22 / 15,
            color: AppColors.white.withValues(alpha: 0.88),
          ),
        ),
      ],
    );
  }
}
