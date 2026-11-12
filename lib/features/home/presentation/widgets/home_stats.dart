import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/equal_height_grid.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/dashboard_attendance_entity.dart';
import 'package:al_mahhaba_school/features/home/presentation/extensions/dashboard_chat_counts.dart';
import 'package:al_mahhaba_school/features/home/presentation/extensions/dashboard_fees_labels.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/home_stat_card.dart';

/// The four Home cards — the latest result, days absent out of those
/// allowed, the next fees installment and messages — each opening its page.
class HomeStats extends StatelessWidget {
  const HomeStats({super.key, required this.dashboard});

  final ChildDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final result = dashboard.latestResult;
    final attendance = dashboard.attendance;
    final fees = dashboard.fees;
    final feesNote = fees?.note(context);
    final chat = dashboard.unreadChat;
    // What the API left empty shows as a dash.
    String orDash(String? text) => text == null || text.isEmpty ? '—' : text;

    Widget note(String text, {Color color = AppColors.ink}) => Text(
      text,
      style: context.textTheme.bodySmall?.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: color,
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
          value: _absences(attendance),
          subtitle: l10n.daysAbsent,
          footer: attendance.exceededAbsenceDays > 0
              ? note(
                  l10n.absenceDaysOver(attendance.exceededAbsenceDays),
                  color: AppColors.error,
                )
              : attendance.allowedAbsenceDays > 0
              ? note(l10n.absenceDaysLeft(attendance.remainingAbsenceDays))
              : null,
          onTap: () => context.go(AppRoutes.attendance),
        ),
        HomeStatCard(
          title: l10n.fees,
          icon: AppIcons.navFees,
          value: fees?.amountLabel(context) ?? '—',
          subtitle: fees?.subtitle(context) ?? l10n.noFeesYet,
          footer: feesNote == null ? null : note(feesNote),
          onTap: () => context.go(AppRoutes.fees),
        ),
        HomeStatCard(
          title: l10n.schoolChat,
          icon: AppIcons.navChat,
          value: l10n.newCount(chat.total),
          subtitle: l10n.messagesAndNotices(chat.messages, chat.notices),
          highlighted: true,
          onTap: () => context.push(AppRoutes.chat),
        ),
      ],
    );
  }

  /// "1/4": days absent out of those allowed; just the days with no limit.
  static String _absences(DashboardAttendanceEntity attendance) =>
      attendance.allowedAbsenceDays > 0
      ? '${attendance.actualAbsenceDays}/${attendance.allowedAbsenceDays}'
      : '${attendance.actualAbsenceDays}';
}
