import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/equal_height_grid.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';
import 'package:al_mahhaba_school/core/widgets/progress_bar.dart';
import 'package:al_mahhaba_school/features/home/data/mock_home.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/home_header.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/home_stat_card.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/main_nav_bar.dart';

/// Parent home: today's status, results, attendance, fees and chat for the
/// selected child, and things that need a reply.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedChild = 0;

  @override
  Widget build(BuildContext context) {
    final dashboard = mockDashboards[_selectedChild];
    final chatUnread = mockDashboards.fold(0, (sum, d) => sum + d.unread);
    final navBottom = math.max(24.h, MediaQuery.paddingOf(context).bottom + 8);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeHeader(
                  selectedChild: _selectedChild,
                  onChildSelected: (index) =>
                      setState(() => _selectedChild = index),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    // Bottom room so the last item scrolls above the nav bar.
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      4.h,
                      20.w,
                      navBottom + 68.h + 24.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 14.h,
                      children: [
                        _TodayBanner(dashboard),
                        _Stats(dashboard),
                        _NeedsAttention(dashboard),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: navBottom,
              child: MainNavBar(current: MainTab.home, chatUnread: chatUnread),
            ),
          ],
        ),
      ),
    );
  }
}

String _locale(BuildContext context) =>
    Localizations.localeOf(context).toString();

class _TodayBanner extends StatelessWidget {
  const _TodayBanner(this.dashboard);

  final ChildDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final absent = dashboard.absentToday;
    final foreground = absent ? AppColors.white : AppColors.ink;
    final date = DateFormat('EEEE, MMM d', _locale(context)).format(mockToday);

    return Material(
      color: absent ? AppColors.mahabbahRed : AppColors.blush,
      borderRadius: BorderRadius.circular(16.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(AppRoutes.attendance),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            spacing: 12.w,
            children: [
              IconBox(
                AppIcons.calendarToday,
                size: 38.r,
                iconSize: 18.r,
                radius: 12.r,
                background: AppColors.white.withValues(alpha: 0.7),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${context.l10n.today} · $date',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: foreground.withValues(alpha: 0.85),
                      ),
                    ),
                    Text(
                      dashboard.todayStatus,
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 15.sp,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: foreground,
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

class _Stats extends StatelessWidget {
  const _Stats(this.dashboard);

  final ChildDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final month = DateFormat.MMM(_locale(context)).format(mockToday);
    String percent(double value) => '${(value * 100).round()}%';

    Widget note(String text) => Text(
      text,
      style: context.textTheme.bodySmall?.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    );

    return EqualHeightGrid(
      columns: 2,
      spacing: 10.w,
      children: [
        HomeStatCard(
          title: l10n.results,
          icon: AppIcons.navResults,
          value: percent(dashboard.average),
          subtitle: dashboard.averageNote,
          footer: ProgressBar(value: dashboard.average, height: 5),
          onTap: () => context.go(AppRoutes.results),
        ),
        HomeStatCard(
          title: l10n.attendance,
          icon: AppIcons.calendarPresent,
          value: dashboard.presentDays,
          subtitle: l10n.daysPresentIn(month),
          footer: note(dashboard.attendanceNote),
          onTap: () => context.go(AppRoutes.attendance),
        ),
        HomeStatCard(
          title: l10n.fees,
          icon: AppIcons.navFees,
          value: percent(dashboard.feesPaid),
          subtitle: l10n.ofTheYearPaid,
          footer: note(dashboard.feesNote),
          onTap: () => context.go(AppRoutes.fees),
        ),
        HomeStatCard(
          title: l10n.schoolChat,
          icon: AppIcons.navChat,
          value: l10n.newCount(dashboard.unread),
          subtitle: dashboard.lastMessage,
          highlighted: true,
          onTap: () => context.push(AppRoutes.chat),
        ),
      ],
    );
  }
}

class _NeedsAttention extends StatelessWidget {
  const _NeedsAttention(this.dashboard);

  final ChildDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8.h,
      children: [
        Text(
          context.l10n.needsYourAttention,
          style: textTheme.titleLarge?.copyWith(fontSize: 16.sp, height: 1.3),
        ),
        for (final item in dashboard.attention)
          Material(
            color: AppColors.blush,
            borderRadius: BorderRadius.circular(14.r),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: switch (item.link) {
                AttentionLink.chat => () => context.push(AppRoutes.chat),
                AttentionLink.fees => () => context.go(AppRoutes.fees),
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Row(
                  spacing: 12.w,
                  children: [
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: const BoxDecoration(
                        color: AppColors.actionRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.text,
                        style: textTheme.bodyMedium?.copyWith(
                          height: 19 / 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    AppSvgIcon(
                      AppIcons.chevronRight,
                      size: 16.r,
                      color: AppColors.mahabbahRed,
                      matchTextDirection: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
