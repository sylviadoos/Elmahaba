import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/children_context.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/no_children_state.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_event.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_state.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_view_model.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/final_result_card.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/report_card_button.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_activities_card.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_info_card.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_subjects_section.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/results_skeleton.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/parent_tab_page.dart';

/// The selected child's latest result: the final result, every subject's
/// mark (tap one for its parts) and the activities.
class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ResultsViewModel>(),
      child: const _ResultsView(),
    );
  }
}

class _ResultsView extends StatefulWidget {
  const _ResultsView();

  @override
  State<_ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends State<_ResultsView> {
  /// The subject shown open, by its section and its place in it; the first
  /// counted subject at first.
  (int, int)? _open = (0, 0);

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  /// Whose result is shown.
  int? _shownId;

  /// The selected child's latest result; nothing to load without children.
  void _loadResult() {
    final child = context.read<ChildrenViewModel>().state.selectedChild;
    if (child == null) return;
    // Another child: their first subject opens.
    if (child.studentId != _shownId && _shownId != null) {
      setState(() => _open = (0, 0));
    }
    _shownId = child.studentId;
    context.read<ResultsViewModel>().doAction(
      LoadLatestResultEvent(child.studentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final childrenState = context.select(
      (ChildrenViewModel viewModel) => viewModel.state.children,
    );
    final children = childrenState.data ?? const <ChildEntity>[];

    return BlocListener<ChildrenViewModel, ChildrenState>(
      // The children arrived or changed (a child linked, the list
      // refreshed), or another one was picked, here or on another page.
      listenWhen: (previous, current) =>
          previous.children.data != current.children.data ||
          current.showsOtherChildThan(previous),
      listener: (context, state) => _loadResult(),
      child: ParentTabPage(
        title: context.l10n.results,
        selectedChild: context.watchSelectedChildIndex(),
        onChildSelected: (index) =>
            context.selectChild(children[index].studentId),
        children: [
          if (children.isEmpty)
            NoChildrenState(
              children: childrenState,
              loading: const ResultsSkeleton(),
            )
          else
            BlocBuilder<ResultsViewModel, ResultsState>(
              builder: (context, state) => state.when(
                initial: () => const ResultsSkeleton(),
                loading: () => const ResultsSkeleton(),
                error: (exception) => StateMessage(
                  icon: AppIcons.navResults,
                  title: exception.localizedMessage(context),
                  action: AppButton(
                    label: context.l10n.tryAgain,
                    expand: false,
                    onPressed: _loadResult,
                  ),
                ),
                success: (result) => result == null
                    ? StateMessage(
                        icon: AppIcons.navResults,
                        title: context.l10n.noResultsYet,
                      )
                    : _result(context, result),
              ),
            ),
        ],
      ),
    );
  }

  Widget _result(BuildContext context, ResultDetailsEntity result) {
    final l10n = context.l10n;
    final sections = [
      (l10n.subjects, l10n.countedInFinalResult, result.subjectsIncluded),
      (
        l10n.otherSubjects,
        l10n.notCountedInFinalResult,
        result.subjectsNotIncluded,
      ),
      (l10n.highLevel, l10n.highLevelNote, result.highLevel),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 18.h,
      children: [
        ResultInfoCard(result: result),
        FinalResultCard(result: result),
        for (final (section, (title, note, subjects)) in sections.indexed)
          if (subjects.isNotEmpty)
            ResultSubjectsSection(
              title: title,
              note: note,
              subjects: subjects,
              usesColors: result.usesColors,
              openIndex: _open?.$1 == section ? _open?.$2 : null,
              // Tapping the open one closes it.
              onToggle: (index) => setState(
                () =>
                    _open = _open == (section, index) ? null : (section, index),
              ),
            ),
        if (result.activities.isNotEmpty)
          ResultActivitiesCard(activities: result.activities),
        const ReportCardButton(),
      ],
    );
  }
}
