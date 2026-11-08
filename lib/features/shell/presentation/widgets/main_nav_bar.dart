import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

enum MainTab { home, chat, results, attendance, fees }

/// Floating rounded bottom bar of the parent app. `ParentShellPage` keeps
/// it in place over the tabs.
class MainNavBar extends StatelessWidget {
  const MainNavBar({
    super.key,
    required this.current,
    required this.onSelected,
    this.chatUnread = 0,
  });

  final MainTab current;

  /// A tab other than [current] was tapped.
  final ValueChanged<MainTab> onSelected;

  /// Shown as a badge on Chat.
  final int chatUnread;

  /// From the bottom of the screen to the bar.
  static double bottomOffset(BuildContext context) =>
      math.max(24.h, MediaQuery.paddingOf(context).bottom + 8);

  /// Room under a tab's content, so its end scrolls above the bar.
  static double contentPadding(BuildContext context) =>
      bottomOffset(context) + 68.h + 24.h;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Chat in the middle.
    final items = [
      (MainTab.home, AppIcons.navHome, l10n.home),
      (MainTab.results, AppIcons.navResults, l10n.results),
      (MainTab.chat, AppIcons.navChat, l10n.chat),
      (MainTab.attendance, AppIcons.navAttendance, l10n.attendance),
      (MainTab.fees, AppIcons.navFees, l10n.fees),
    ];

    return Container(
      height: 68.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(34.r),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.16),
            offset: Offset(0, 14.h),
            blurRadius: 34.r,
          ),
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.06),
            offset: Offset(0, 2.h),
            blurRadius: 6.r,
          ),
        ],
      ),
      child: Row(
        children: [
          for (final (tab, icon, label) in items)
            Expanded(
              child: _NavItem(
                icon: icon,
                label: label,
                isActive: tab == current,
                badge: tab == MainTab.chat ? chatUnread : 0,
                onTap: () {
                  if (tab != current) onSelected(tab);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.badge,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool isActive;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.actionRed : AppColors.slate;

    return Semantics(
      selected: isActive,
      button: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 2.h,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52.w,
                  height: 30.h,
                  decoration: ShapeDecoration(
                    color: isActive ? AppColors.blush : Colors.transparent,
                    shape: const StadiumBorder(),
                  ),
                ),
                AppSvgIcon(icon, size: 20.r, color: color),
                if (badge > 0)
                  PositionedDirectional(
                    top: -2.h,
                    end: 6.w,
                    child: Container(
                      constraints: BoxConstraints(minWidth: 18.r),
                      height: 18.r,
                      padding: EdgeInsets.symmetric(horizontal: 4.r),
                      alignment: Alignment.center,
                      decoration: const ShapeDecoration(
                        color: AppColors.actionRed,
                        shape: StadiumBorder(
                          side: BorderSide(color: AppColors.white, width: 2),
                        ),
                      ),
                      child: Text(
                        '$badge',
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 11.sp,
                          height: 1,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: 11.sp,
                height: 1.3,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
