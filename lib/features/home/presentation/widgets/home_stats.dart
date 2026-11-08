import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/equal_height_grid.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/dashboard_fees_entity.dart';
import 'package:al_mahhaba_school/features/home/presentation/extensions/dashboard_fees_labels.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/home_stat_card.dart';

/// The four Home cards — the latest result, this month's attendance, fees
/// paid and messages — each opening its page.
class HomeStats extends StatelessWidget {
  const HomeStats({super.key, required this.dashboard});

  final ChildDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final result = dashboard.latestResult;
    final counts = dashboard.attendance.monthCounts;
    final fees = dashboard.fees;
    final messages = dashboard.messages;
    // What the API left empty shows as a dash.
    String orDash(String? text) => text == null || text.isEmpty ? '—' : text;

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
          // The year it's for, then the school's title for it.
          value: orDash(result?.academicYear),
          subtitle: result == null ? l10n.noResultsYet : result.title,
          onTap: () => context.go(AppRoutes.results),
        ),
        HomeStatCard(
          title: l10n.attendance,
          icon: AppIcons.calendarPresent,
          value: '${counts.presentDays}/${counts.schoolDays}',
          subtitle: l10n.daysPresentIn(
            DateFormat.MMM(locale).format(DateTime.now()),
          ),
          footer: note(
            l10n.absentLateCount(counts.absentDays, counts.lateDays),
          ),
          onTap: () => context.go(AppRoutes.attendance),
        ),
        HomeStatCard(
          title: l10n.fees,
          icon: AppIcons.navFees,
          value: fees == null ? '—' : _paidPercent(fees),
          subtitle: fees == null ? l10n.noFeesYet : l10n.ofTheYearPaid,
          footer: fees == null ? null : note(fees.note(context)),
          onTap: () => context.go(AppRoutes.fees),
        ),
        HomeStatCard(
          title: l10n.schoolChat,
          icon: AppIcons.navChat,
          value: l10n.newCount(messages.total),
          subtitle: l10n.messagesAndNotices(
            messages.messages,
            messages.notices,
          ),
          highlighted: true,
          onTap: () => context.push(AppRoutes.chat),
        ),
      ],
    );
  }

  /// "32%"; nothing to pay counts as all paid.
  static String _paidPercent(DashboardFeesEntity fees) {
    final share = fees.totalAmount > 0
        ? fees.paidAmount / fees.totalAmount
        : 1.0;
    return '${(share.clamp(0, 1) * 100).round()}%';
  }
}
