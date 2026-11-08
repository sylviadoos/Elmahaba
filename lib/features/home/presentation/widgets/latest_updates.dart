import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_result_entity.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/latest_updates_bloc.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/latest_updates_intent.dart';
import 'package:al_mahhaba_school/features/home/presentation/extensions/latest_labels.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/latest_card.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/latest_row.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';
import 'package:al_mahhaba_school/features/homework/presentation/extensions/homework_labels.dart';
import 'package:al_mahhaba_school/features/homework/presentation/widgets/homework_due_badge.dart';

/// Under Home's cards: the child's newest announcements, homework and
/// results from `LatestUpdatesBloc`, each opening its page.
class LatestUpdates extends StatelessWidget {
  const LatestUpdates({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14.h,
      children: const [
        _LatestAnnouncements(),
        _LatestHomework(),
        _LatestResults(),
      ],
    );
  }
}

void _retry(BuildContext context) =>
    context.read<LatestUpdatesBloc>().add(const RetryUpdatesIntent());

class _LatestAnnouncements extends StatelessWidget {
  const _LatestAnnouncements();

  @override
  Widget build(BuildContext context) {
    final latest = context.select(
      (LatestUpdatesBloc bloc) => bloc.state.announcements,
    );
    // Announcements are in the chat with the school.
    void open() => context.push(AppRoutes.chat);

    return LatestCard<AnnouncementEntity>(
      title: context.l10n.announcements,
      icon: AppIcons.megaphoneGeneral,
      latest: latest,
      emptyText: context.l10n.noAnnouncements,
      onSeeAll: open,
      onRetry: () => _retry(context),
      row: (announcement) => LatestRow(
        title: announcement.title,
        subtitle: announcement.body,
        unread: !announcement.isRead,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4.w,
          children: [
            if (announcement.attachments.isNotEmpty)
              AppSvgIcon(AppIcons.paperclip, size: 12.r, color: AppColors.mist),
            ?_date(context, announcement.publishedAt),
          ],
        ),
        onTap: open,
      ),
    );
  }
}

class _LatestHomework extends StatelessWidget {
  const _LatestHomework();

  @override
  Widget build(BuildContext context) {
    final latest = context.select(
      (LatestUpdatesBloc bloc) => bloc.state.homework,
    );
    final childId = context.select(
      (LatestUpdatesBloc bloc) => bloc.state.childId,
    );
    void open() => context.push(AppRoutes.homework, extra: childId);

    return LatestCard<HomeworkEntity>(
      title: context.l10n.homework,
      icon: AppIcons.book,
      latest: latest,
      emptyText: context.l10n.noHomework,
      onSeeAll: open,
      onRetry: () => _retry(context),
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
        onTap: open,
      ),
    );
  }
}

class _LatestResults extends StatelessWidget {
  const _LatestResults();

  @override
  Widget build(BuildContext context) {
    final latest = context.select(
      (LatestUpdatesBloc bloc) => bloc.state.results,
    );
    void open() => context.go(AppRoutes.results);

    return LatestCard<LatestResultEntity>(
      title: context.l10n.results,
      icon: AppIcons.navResults,
      latest: latest,
      emptyText: context.l10n.noResultsYet,
      onSeeAll: open,
      onRetry: () => _retry(context),
      row: (result) => LatestRow(
        title: result.title,
        subtitle: result.academicYear,
        unread: !result.isRead,
        trailing: _date(context, result.publishedAt),
        onTap: open,
      ),
    );
  }
}

Widget? _date(BuildContext context, DateTime? at) =>
    at == null ? null : LatestRowDate(at.latestDayLabel(context));
