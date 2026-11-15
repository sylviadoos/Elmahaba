import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/core/widgets/red_header_title.dart';

/// Add children's red header: back, the "Last step" badge and the title.
class AddChildrenHeader extends StatelessWidget {
  const AddChildrenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return RedHeader(
      horizontalPadding: 24,
      bottomPadding: 38,
      watermarkTop: 74,
      watermarkSize: const Size(250, 178),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16.h,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppBackButton(fallbackRoute: AppRoutes.profile),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: ShapeDecoration(
                  color: AppColors.white.withValues(alpha: 0.16),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  l10n.lastStep,
                  style: context.textTheme.bodySmall?.copyWith(
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          RedHeaderTitle(
            title: l10n.addYourChildren,
            subtitle: l10n.addChildrenSubtitle,
          ),
        ],
      ),
    );
  }
}
