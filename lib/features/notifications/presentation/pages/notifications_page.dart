import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/features/children/data/mock_children.dart';
import 'package:al_mahhaba_school/features/notifications/data/mock_notifications.dart';

/// Notifications grouped by day, filterable by child.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  /// Index in mockChildren; null shows every child.
  int? _childFilter;

  // TODO: mark as read through the API (Cubit).
  bool _allRead = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final shown = mockNotifications.where(
      (n) =>
          _childFilter == null ||
          n.childIndex == null ||
          n.childIndex == _childFilter,
    );
    final groupLabels = {
      NotificationGroup.today: l10n.today,
      NotificationGroup.yesterday: l10n.yesterday,
      NotificationGroup.earlier: l10n.earlier,
    };

    final items = <Widget>[
      for (final group in NotificationGroup.values)
        if (shown.any((n) => n.group == group)) ...[
          _GroupLabel(groupLabels[group]!),
          for (final notification in shown.where((n) => n.group == group))
            _NotificationTile(
              notification: notification,
              isUnread: notification.isUnread && !_allRead,
            ),
        ],
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RedHeader(
              horizontalPadding: 16,
              bottomPadding: 36,
              watermarkTop: 20,
              watermarkSize: const Size(200, 143),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 14.h,
                children: [
                  Row(
                    spacing: 10.w,
                    children: [
                      const AppBackButton(fallbackRoute: AppRoutes.home),
                      Expanded(
                        child: Text(
                          l10n.notifications,
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontSize: 24.sp,
                            height: 1.25,
                            letterSpacing: 0,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _allRead = true),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.white.withValues(
                            alpha: 0.16,
                          ),
                          foregroundColor: AppColors.white,
                          minimumSize: Size(0, 44.h),
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          textStyle: context.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(l10n.markAllRead),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _FilterChip(
                        label: l10n.filterAll,
                        isSelected: _childFilter == null,
                        onTap: () => setState(() => _childFilter = null),
                      ),
                      for (final (index, child) in mockChildren.indexed)
                        _FilterChip(
                          label: child.firstName,
                          isSelected: _childFilter == index,
                          onTap: () => setState(() => _childFilter = index),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  4.h,
                  16.w,
                  math.max(40.h, bottomInset + 16),
                ),
                itemCount: items.length,
                itemBuilder: (context, index) => items[index],
                separatorBuilder: (context, index) => SizedBox(height: 6.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      child: Material(
        color: isSelected ? AppColors.white : Colors.transparent,
        shape: StadiumBorder(
          side: isSelected
              ? BorderSide.none
              : BorderSide(color: AppColors.white.withValues(alpha: 0.35)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 38.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            // widthFactor keeps the chip as wide as its label inside the Wrap.
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  height: 1.2,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.mahabbahRed : AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 12.h, 4.w, 4.h),
      child: Text(
        label.toUpperCase(),
        style: context.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.slate,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.isUnread});

  final AppNotification notification;
  final bool isUnread;

  void _open(BuildContext context) => switch (notification.type) {
    NotificationType.chat => context.push(AppRoutes.chat),
    NotificationType.results => context.go(AppRoutes.results),
    NotificationType.attendance ||
    NotificationType.holiday => context.go(AppRoutes.attendance),
    NotificationType.fees => context.go(AppRoutes.fees),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final isHoliday = notification.type == NotificationType.holiday;
    final childIndex = notification.childIndex;
    final isGeneral = childIndex == null;
    final icon = switch (notification.type) {
      NotificationType.chat => AppIcons.navChat,
      NotificationType.results => AppIcons.navResults,
      NotificationType.attendance => AppIcons.calendarToday,
      NotificationType.fees => AppIcons.navFees,
      NotificationType.holiday => AppIcons.sunHoliday,
    };

    return Material(
      color: isUnread ? AppColors.blush : AppColors.white,
      borderRadius: BorderRadius.circular(16.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _open(context),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12.w,
            children: [
              IconBox(
                icon,
                size: 42.r,
                iconSize: 19.r,
                radius: 14.r,
                background: isHoliday
                    ? AppColors.gold
                    : isUnread
                    ? AppColors.white
                    : AppColors.blush,
                color: isHoliday ? AppColors.goldText : AppColors.mahabbahRed,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3.h,
                  children: [
                    Row(
                      spacing: 6.w,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 1.h,
                          ),
                          decoration: ShapeDecoration(
                            color: isGeneral
                                ? AppColors.mahabbahRed
                                : AppColors.surface,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            isGeneral
                                ? l10n.allParents
                                : mockChildren[childIndex].firstName,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 11.sp,
                              height: 1.4,
                              fontWeight: FontWeight.w700,
                              color: isGeneral
                                  ? AppColors.white
                                  : AppColors.ink,
                            ),
                          ),
                        ),
                        Text(
                          notification.time,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.slate,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      notification.title,
                      style: textTheme.bodyMedium?.copyWith(
                        height: 19 / 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      notification.detail,
                      style: textTheme.bodySmall?.copyWith(
                        height: 18 / 13,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUnread)
                Semantics(
                  label: l10n.unread,
                  child: Container(
                    width: 10.r,
                    height: 10.r,
                    margin: EdgeInsets.only(top: 6.h),
                    decoration: const BoxDecoration(
                      color: AppColors.actionRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
