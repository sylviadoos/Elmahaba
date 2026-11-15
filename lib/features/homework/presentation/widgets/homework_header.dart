import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/child_picker.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/status_filter_chip.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_filter.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_bloc.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_intent.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_state.dart';
import 'package:al_mahhaba_school/features/homework/presentation/extensions/homework_labels.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/settings_button.dart';

/// Homework's red header, from the [HomeworkBloc]: back, "Homework" with
/// how many there are (and how many new), Settings, the child picker, and
/// a chip for each [HomeworkFilter].
class HomeworkHeader extends StatelessWidget {
  const HomeworkHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return BlocBuilder<HomeworkBloc, HomeworkState>(
      buildWhen: (previous, current) =>
          previous.children != current.children ||
          previous.studentId != current.studentId ||
          previous.filter != current.filter ||
          previous.page?.total != current.page?.total ||
          previous.page?.unread != current.page?.unread,
      builder: (context, state) {
        final bloc = context.read<HomeworkBloc>();
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
                          l10n.homework,
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
                              l10n.homeworkCount(page.total),
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
                    ShowChildHomeworkIntent(children[index].studentId),
                  ),
                ),
              // Six of them: they scroll sideways rather than wrap.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 8.w,
                  children: [
                    for (final filter in HomeworkFilter.values)
                      StatusFilterChip(
                        label: filter.label(context),
                        isSelected: state.filter == filter,
                        onTap: () => bloc.add(FilterHomeworkIntent(filter)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
