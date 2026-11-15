import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/child_display.dart';

/// A child on the parent's account: initial, name, grade and class, the end
/// of the national ID, and a "Linked" badge.
class LinkedChildCard extends StatelessWidget {
  const LinkedChildCard({super.key, required this.child});

  final ChildEntity child;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final name = child.displayName(context);

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        spacing: 12.w,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
            child: Text(
              name.characters.first,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 17.sp,
                height: 1,
                fontWeight: FontWeight.w700,
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
                  name,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 15.sp,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  child.summary(context),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.slate,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: const ShapeDecoration(
              color: AppColors.successBg,
              shape: StadiumBorder(),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4.w,
              children: [
                AppSvgIcon(
                  AppIcons.check,
                  size: 11.r,
                  color: AppColors.success,
                ),
                Text(
                  l10n.linked,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11.sp,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
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
