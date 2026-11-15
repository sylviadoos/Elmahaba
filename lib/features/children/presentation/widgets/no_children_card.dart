import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/dashed_border.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';

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
