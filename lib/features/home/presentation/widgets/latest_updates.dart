import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/extensions/open_announcement.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_result_entity.dart';
import 'package:al_mahhaba_school/features/home/presentation/extensions/latest_labels.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/latest_card.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/latest_row.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';
import 'package:al_mahhaba_school/features/homework/presentation/extensions/homework_labels.dart';
import 'package:al_mahhaba_school/features/homework/presentation/widgets/homework_due_badge.dart';

/// Under Home's cards: the child's newest announcements, homework and
/// results from their [dashboard], each opening its page.
class LatestUpdates extends StatelessWidget {
  const LatestUpdates({super.key, required this.dashboard, this.childId});

  final ChildDashboardEntity dashboard;

  /// The child shown, by `studentId`, for Homework.
  final int? childId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void openAnnouncements() =>
        context.push(AppRoutes.announcements, extra: childId);
    void openHomework() => context.push(AppRoutes.homework, extra: childId);
    void openResults() => context.go(AppRoutes.results);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14.h,
      children: [
        LatestCard<AnnouncementEntity>(
          title: l10n.announcements,
          icon: AppIcons.megaphoneGeneral,
          latest: dashboard.announcements,
          emptyText: l10n.noAnnouncements,
          onSeeAll: openAnnouncements,
          row: (announcement) => LatestRow(
            title: announcement.title,
            subtitle: announcement.body,
            unread: !announcement.isRead,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4.w,
              children: [
                if (announcement.attachments.isNotEmpty)
                  AppSvgIcon(
                    AppIcons.paperclip,
                    size: 12.r,
                    color: AppColors.mist,
                  ),
                ?_date(context, announcement.publishedAt),
              ],
            ),
            // Home has the announcement itself, so tapping it opens that
            // one, with no list loaded and none scrolled through.
            onTap: () =>
                context.openAnnouncement(announcement, studentId: childId),
          ),
        ),
        LatestCard<HomeworkEntity>(
          title: l10n.homework,
          icon: AppIcons.book,
          latest: dashboard.homework,
          emptyText: l10n.noHomework,
          onSeeAll: openHomework,
          row: (homework) => LatestRow(
            title: homework.title,
            subtitle: homework.subject,
            unread: !homework.isRead,
            // Under the title, leaving the subject some room.
            subtitleEnd: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 220.w),
              child: HomeworkDueBadge(
                status: homework.dueStatus,
                label: homework.dueLabel(context),
              ),
            ),
            onTap: openHomework,
          ),
        ),
        LatestCard<LatestResultEntity>(
          title: l10n.results,
          icon: AppIcons.navResults,
          latest: dashboard.results,
          emptyText: l10n.noResultsYet,
          onSeeAll: openResults,
          row: (result) => LatestRow(
            title: result.title,
            subtitle: result.academicYear,
            unread: !result.isRead,
            trailing: _date(context, result.publishedAt),
            onTap: openResults,
          ),
        ),
      ],
    );
  }
}

Widget? _date(BuildContext context, DateTime? at) =>
    at == null ? null : LatestRowDate(at.latestDayLabel(context));
