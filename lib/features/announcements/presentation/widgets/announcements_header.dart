import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_intent.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/child_picker.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/settings_button.dart';

/// Announcements' red header, from the [AnnouncementsBloc]: back,
/// "Announcements" with how many there are (and how many new), Settings,
/// and the child picker.
class AnnouncementsHeader extends StatelessWidget {
  const AnnouncementsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
      buildWhen: (previous, current) =>
          previous.children != current.children ||
          previous.studentId != current.studentId ||
          previous.page?.total != current.page?.total ||
          previous.page?.unread != current.page?.unread,
      builder: (context, state) {
        final bloc = context.read<AnnouncementsBloc>();
        final page = state.page;
        final children = state.children;
        final shown = state.shownIndex;

        return RedHeader(
          horizontalPadding: 16,
          bottomPadding: 40,
          watermarkTop: 20,
          watermarkSize: const Size(200, 143),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12.h,
            children: [
              Row(
                spacing: 10.w,
                children: [
                  const AppBackButton(fallbackRoute: AppRoutes.home),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.announcements,
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 24.sp,
                            height: 28 / 24,
                            letterSpacing: 0,
                            color: AppColors.white,
                          ),
                        ),
                        if (page != null)
                          Text(
                            [
                              l10n.announcementsCount(page.total),
                              if (page.unread > 0) l10n.newCount(page.unread),
                            ].join(' · '),
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.white.withValues(alpha: 0.88),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SettingsButton(),
                ],
              ),
              if (children.isNotEmpty)
                ChildPicker(
                  children: children,
                  selected: shown < 0 ? 0 : shown,
                  onSelected: (index) => bloc.add(
                    ShowChildAnnouncementsIntent(children[index].studentId),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
