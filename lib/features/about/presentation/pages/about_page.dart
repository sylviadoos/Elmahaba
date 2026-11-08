import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';
import 'package:al_mahhaba_school/core/widgets/principal_card.dart';
import 'package:al_mahhaba_school/core/widgets/visitor_header.dart';
import 'package:al_mahhaba_school/core/widgets/visitor_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/parent_context.dart';

/// The school's vision, mission and legacy.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return VisitorPage(
      header: VisitorHeader(title: l10n.aboutUs, subtitle: l10n.aboutSubtitle),
      // Also opened from Profile, where the parent is already signed in.
      showLogin: context.watchParent() == null,
      children: const [
        _VisionCard(),
        _MissionSection(),
        _LegacySection(),
        PrincipalCard(),
      ],
    );
  }
}

class _VisionCard extends StatelessWidget {
  const _VisionCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22.r),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 200.h),
        child: ColoredBox(
          color: AppColors.blush,
          child: Stack(
            children: [
              PositionedDirectional(
                end: -40.w,
                bottom: -60.h,
                child: Container(
                  width: 220.r,
                  height: 220.r,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              PositionedDirectional(
                end: -16.w,
                bottom: -40.h,
                child: Image.asset(
                  AppImages.studentBoy,
                  width: 166.r,
                  height: 220.r,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10.h,
                  children: [
                    _IconHeading(
                      icon: AppIcons.eyeVision,
                      text: l10n.ourVision,
                      solid: true,
                    ),
                    SizedBox(
                      width: 190.w,
                      child: Text(
                        l10n.visionBody,
                        style: context.textTheme.bodyLarge?.copyWith(
                          height: 25 / 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionSection extends StatelessWidget {
  const _MissionSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final missions = [
      l10n.mission1,
      l10n.mission2,
      l10n.mission3,
      l10n.mission4,
      l10n.mission5,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12.h,
      children: [
        _IconHeading(icon: AppIcons.targetMission, text: l10n.ourMission),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8.h,
          children: [
            for (final (index, mission) in missions.indexed)
              _MissionItem(number: index + 1, text: mission),
          ],
        ),
      ],
    );
  }
}

class _MissionItem extends StatelessWidget {
  const _MissionItem({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.w,
        children: [
          Container(
            width: 26.r,
            height: 26.r,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.actionRed,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 13.sp,
                height: 1,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                height: 21 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegacySection extends StatelessWidget {
  const _LegacySection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14.h,
      children: [
        _IconHeading(icon: AppIcons.awardLegacy, text: l10n.ourLegacy),
        Text(
          l10n.legacyBody,
          style: textTheme.bodyLarge?.copyWith(
            fontSize: 15.sp,
            height: 24 / 15,
            color: AppColors.slate,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 4.h),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: AppColors.maroon,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            l10n.legacyQuote,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 16.sp,
              height: 24 / 16,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Icon tile + heading. [solid] uses a red tile with a white icon and red
/// text (vision card); otherwise a blush tile and dark text.
class _IconHeading extends StatelessWidget {
  const _IconHeading({
    required this.icon,
    required this.text,
    this.solid = false,
  });

  final String icon;
  final String text;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10.w,
      children: [
        IconBox(
          icon,
          size: 36.r,
          iconSize: 18.r,
          radius: 12.r,
          background: solid ? AppColors.mahabbahRed : AppColors.blush,
          color: solid ? AppColors.white : AppColors.mahabbahRed,
        ),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.titleLarge?.copyWith(
              color: solid ? AppColors.mahabbahRed : null,
            ),
          ),
        ),
      ],
    );
  }
}
