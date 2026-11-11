import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/segmented_control.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/retry_or_log_in_button.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/children_context.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/no_children_state.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_certificate_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/bloc/monthly_results_bloc.dart';
import 'package:al_mahhaba_school/features/results/presentation/bloc/monthly_results_intent.dart';
import 'package:al_mahhaba_school/features/results/presentation/extensions/child_certificate.dart';
import 'package:al_mahhaba_school/features/results/presentation/extensions/results_forms.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_event.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_view_model.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/certificate_download_button.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/final_result_card.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/monthly_results_view.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_activities_card.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_info_card.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_subjects_section.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/results_skeleton.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/parent_tab_page.dart';

/// The selected child's results, in whichever form the school published
/// them: the monthly results (a month at a time, with the certificate to
/// download) and the latest result (the final result, every subject's mark
/// — tap one for its parts — and the activities). With both, a switch
/// between them; the newer shows first.
class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ResultsViewModel>()),
        BlocProvider(create: (_) => getIt<MonthlyResultsBloc>()),
      ],
      child: const _ResultsView(),
    );
  }
}

/// The two forms, in the switch's order.
enum _Form { monthly, latest }

class _ResultsView extends StatefulWidget {
  const _ResultsView();

  @override
  State<_ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends State<_ResultsView> {
  /// The latest result's subject shown open, by its section and its place
  /// in it; the first counted subject at first.
  (int, int)? _open = (0, 0);

  /// The form picked in the switch; null shows the newer.
  _Form? _form;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  /// Whose results are shown.
  int? _shownId;

  /// The selected child's results, both forms; nothing to load without
  /// children. Also "Try again": what loaded stays.
  void _loadResults() {
    final child = context.read<ChildrenViewModel>().state.selectedChild;
    if (child == null) return;
    // Another child: as at first.
    if (child.studentId != _shownId && _shownId != null) {
      setState(() {
        _open = (0, 0);
        _form = null;
      });
    }
    _shownId = child.studentId;
    context.read<ResultsViewModel>().doAction(
      LoadLatestResultEvent(child.studentId),
    );
    context.read<MonthlyResultsBloc>().add(
      ShowChildMonthlyIntent(child.studentId),
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
      listener: (context, state) => _loadResults(),
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
            _results(context),
        ],
      ),
    );
  }

  Widget _results(BuildContext context) {
    final l10n = context.l10n;
    final latestState = context.watch<ResultsViewModel>().state;
    final monthlyState = context.select(
      (MonthlyResultsBloc bloc) => bloc.state.results,
    );
    final child = context.select(
      (ChildrenViewModel viewModel) => viewModel.state.selectedChild,
    );
    // Both answered before choosing, so the page doesn't jump.
    bool answered(StateType state) =>
        state == StateType.success || state == StateType.error;
    if (!answered(latestState.state) || !answered(monthlyState.state)) {
      return const ResultsSkeleton();
    }

    final forms = ResultsForms.of(
      monthly: monthlyState.data,
      latest: latestState.data,
    );
    final monthly = forms.monthly;
    final latest = forms.latest;
    // Always one to download: the school's, with the months' marks, or
    // with just the child on it when it sent none.
    final certificate =
        monthlyState.data?.certificate ?? child?.blankCertificate;
    if (monthly == null && latest == null) {
      // One that failed may be the one with results.
      final exception = latestState.exception ?? monthlyState.exception;
      return StateMessage(
        icon: AppIcons.navResults,
        title: exception?.localizedMessage(context) ?? l10n.noResultsYet,
        action: exception == null
            ? null
            : RetryOrLogInButton(exception: exception, onRetry: _loadResults),
      );
    }
    if (latest == null) return MonthlyResultsView(results: monthly!);
    if (monthly == null) {
      return _latest(context, latest, certificate: certificate);
    }

    final form = _form ?? (forms.monthlyIsNewer ? _Form.monthly : _Form.latest);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 18.h,
      children: [
        SegmentedControl(
          options: [
            SegmentOption(l10n.monthlyResults),
            SegmentOption(l10n.latestResult),
          ],
          selected: form.index,
          onSelected: (index) => setState(() => _form = _Form.values[index]),
        ),
        switch (form) {
          _Form.monthly => MonthlyResultsView(results: monthly),
          _Form.latest => _latest(context, latest, certificate: certificate),
        },
      ],
    );
  }

  /// The latest result, and under it the year's [certificate] to download
  /// (null only without a child, which can't be here).
  Widget _latest(
    BuildContext context,
    ResultDetailsEntity result, {
    required MonthlyCertificateEntity? certificate,
  }) {
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
        if (certificate != null)
          CertificateDownloadButton(certificate: certificate),
      ],
    );
  }
}
