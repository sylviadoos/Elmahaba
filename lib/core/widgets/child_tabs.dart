import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

class ChildTab {
  const ChildTab({required this.name, required this.grade, this.unread = 0});

  final String name;
  final String grade;

  /// Unread messages, shown as a badge on tabs that aren't selected.
  final int unread;

  String get initial => name.characters.first;
}

/// Segmented switcher between the parent's children, for the red headers
/// (Home, School chat).
class ChildTabs extends StatelessWidget {
  const ChildTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelected,
    this.showUnread = false,
  });

  final List<ChildTab> tabs;
  final int selected;
  final ValueChanged<int> onSelected;
  final bool showUnread;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        spacing: 4.w,
        children: [
          for (final (index, tab) in tabs.indexed)
            Expanded(
              child: _Tab(
                tab: tab,
                isSelected: index == selected,
                showUnread: showUnread,
                onTap: () => onSelected(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.tab,
    required this.isSelected,
    required this.showUnread,
    required this.onTap,
  });

  final ChildTab tab;
  final bool isSelected;
  final bool showUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final foreground = isSelected ? AppColors.ink : AppColors.white;

    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: isSelected ? AppColors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 48.h,
            padding: EdgeInsetsDirectional.only(start: 6.w, end: 10.w),
            child: Row(
              spacing: 8.w,
              children: [
                Container(
                  width: 34.r,
                  height: 34.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.blush
                        : AppColors.white.withValues(alpha: 0.16),
                  ),
                  child: Text(
                    tab.initial,
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 15.sp,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.mahabbahRed
                          : AppColors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tab.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          height: 17 / 14,
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                      Text(
                        tab.grade,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11.sp,
                          height: 1.3,
                          color: isSelected
                              ? AppColors.slate
                              : AppColors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                if (showUnread && !isSelected && tab.unread > 0)
                  Container(
                    constraints: BoxConstraints(minWidth: 20.r),
                    height: 20.r,
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    alignment: Alignment.center,
                    decoration: const ShapeDecoration(
                      color: AppColors.white,
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      '${tab.unread}',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11.sp,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mahabbahRed,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
