import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/child_tabs.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/features/children/data/mock_children.dart';
import 'package:al_mahhaba_school/features/home/data/mock_home.dart';

/// Greeting, profile and notifications, and the child switcher.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.selectedChild,
    required this.onChildSelected,
  });

  final int selectedChild;
  final ValueChanged<int> onChildSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return RedHeader(
      horizontalPadding: 16,
      bottomPadding: 36,
      watermarkTop: 26,
      watermarkSize: const Size(250, 178),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14.h,
        children: [
          Row(
            spacing: 8.w,
            children: [
              const Expanded(child: _ProfileLink()),
              _RoundIconButton(
                icon: AppIcons.user,
                tooltip: l10n.myProfile,
                onPressed: () => context.push(AppRoutes.profile),
              ),
              _RoundIconButton(
                icon: AppIcons.bell,
                tooltip: l10n.notifications,
                badge: mockNotificationCount,
                onPressed: () => context.push(AppRoutes.notifications),
              ),
            ],
          ),
          ChildTabs(
            tabs: [
              for (final child in mockChildren)
                ChildTab(name: child.firstName, grade: child.grade),
            ],
            selected: selectedChild,
            onSelected: onChildSelected,
          ),
        ],
      ),
    );
  }
}

class _ProfileLink extends StatelessWidget {
  const _ProfileLink();

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return InkWell(
      onTap: () => context.push(AppRoutes.profile),
      borderRadius: BorderRadius.circular(22.r),
      child: Row(
        spacing: 12.w,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              mockParentInitials,
              style: textTheme.titleLarge?.copyWith(
                fontSize: 15.sp,
                height: 1,
                fontWeight: FontWeight.w800,
                color: AppColors.mahabbahRed,
              ),
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.goodMorning,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
                Row(
                  spacing: 4.w,
                  children: [
                    Flexible(
                      child: Text(
                        mockParentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleLarge?.copyWith(
                          height: 22 / 18,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    AppSvgIcon(
                      AppIcons.chevronRight,
                      size: 16.r,
                      color: AppColors.white,
                      matchTextDirection: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.badge = 0,
  });

  final String icon;
  final String tooltip;
  final VoidCallback onPressed;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.white.withValues(alpha: 0.16),
            fixedSize: Size.square(44.r),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: AppSvgIcon(icon, size: 20.r, color: AppColors.white),
        ),
        if (badge > 0)
          PositionedDirectional(
            top: 4.r,
            end: 2.r,
            child: IgnorePointer(
              child: Container(
                constraints: BoxConstraints(minWidth: 18.r),
                height: 18.r,
                padding: EdgeInsets.symmetric(horizontal: 5.r),
                alignment: Alignment.center,
                decoration: const ShapeDecoration(
                  color: AppColors.white,
                  shape: StadiumBorder(),
                ),
                child: Text(
                  '$badge',
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 11.sp,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mahabbahRed,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
