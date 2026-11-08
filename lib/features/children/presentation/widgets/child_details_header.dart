import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/child_display.dart';

/// Red header: back, "Child details", and the [child]'s initial, name,
/// grade and class — once known.
class ChildDetailsHeader extends StatelessWidget {
  const ChildDetailsHeader({super.key, required this.child});

  final ChildEntity? child;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final child = this.child;
    final name = child?.displayName(context) ?? '';

    return RedHeader(
      horizontalPadding: 16,
      bottomPadding: 44,
      watermarkTop: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16.h,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppBackButton(fallbackRoute: AppRoutes.profile),
              Text(
                l10n.childDetails,
                style: textTheme.titleLarge?.copyWith(color: AppColors.white),
              ),
              // As wide as back, so the title stays centred.
              SizedBox(width: 44.r),
            ],
          ),
          Row(
            spacing: 14.w,
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: name.isEmpty
                    ? AppSvgIcon(
                        AppIcons.user,
                        size: 28.r,
                        color: AppColors.mahabbahRed,
                      )
                    : Text(
                        name.characters.first,
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 24.sp,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mahabbahRed,
                        ),
                      ),
              ),
              if (child != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2.h,
                    children: [
                      Text(
                        name,
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 20.sp,
                          height: 1.25,
                          color: AppColors.white,
                        ),
                      ),
                      if (child.gradeAndClass.isNotEmpty)
                        Text(
                          child.gradeAndClass,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.88),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
