import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/dashed_border.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';
import 'package:al_mahhaba_school/features/children/data/models/child_profile.dart';

/// A child found by national ID: initial, name, grade, "Linked" badge and
/// a remove button.
class LinkedChildCard extends StatelessWidget {
  const LinkedChildCard({
    super.key,
    required this.child,
    required this.onRemove,
  });

  final ChildProfile child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

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
              child.fullName.characters.first,
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
                  child.fullName,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 15.sp,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${child.grade} · ${l10n.childIdTail(child.idTail)}',
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
          IconButton(
            onPressed: onRemove,
            tooltip: l10n.removeChild(child.fullName),
            style: IconButton.styleFrom(
              fixedSize: Size.square(44.r),
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: AppSvgIcon(
              AppIcons.trash,
              size: 18.r,
              color: AppColors.slate,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashed placeholder shown before any child is added.
class NoChildrenCard extends StatelessWidget {
  const NoChildrenCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashedBorder(
      color: AppColors.line,
      radius: 18.r,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
        child: Column(
          spacing: 8.h,
          children: [
            IconBox(AppIcons.plus, size: 44.r, iconSize: 20.r, circle: true),
            Text(
              context.l10n.noChildrenYet,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
