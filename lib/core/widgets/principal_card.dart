import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// "School Principal — Mrs. Ahlam Louis Riad" with an initials avatar.
/// [compact] is the smaller version used inside news articles.
class PrincipalCard extends StatelessWidget {
  const PrincipalCard({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return Container(
      padding: compact
          ? EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h)
          : EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular((compact ? 18 : 20).r),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        spacing: 14.w,
        children: [
          Container(
            width: (compact ? 44 : 48).r,
            height: (compact ? 44 : 48).r,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
            child: Text(
              l10n.principalInitials,
              style: textTheme.titleLarge?.copyWith(
                fontSize: (compact ? 15 : 17).sp,
                fontWeight: FontWeight.w800,
                color: AppColors.maroon,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2.h,
              children: [
                Text(
                  l10n.schoolPrincipal,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.slate,
                  ),
                ),
                Text(
                  l10n.principalName,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: (compact ? 15 : 16).sp,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
