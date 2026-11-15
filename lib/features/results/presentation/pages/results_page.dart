import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/page_refresher.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/retry_or_log_in_button.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/children_context.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/no_children_state.dart';
import 'package:al_mahhaba_school/features/results/presentation/extensions/child_certificate.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_event.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_view_model.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_details_view.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_filter.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/results_skeleton.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/parent_tab_page.dart';

/// The selected child's results: the newest one published shows first, and
/// a filter above it picks any other — a month or a term. Under a month's,
/// the certificate to download, with every month of the year on it. Kept
/// up to date while it shows (see [PageRefresher]).
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
  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  /// The selected child's results; nothing to load without children. Also
  /// "Try again".
  void _loadResults() {
    final child = context.read<ChildrenViewModel>().state.selectedChild;
    if (child == null) return;
    context.read<ResultsViewModel>().doAction(
      LoadResultsEvent(child.studentId),
    );
  }

  /// One published since shows: the tab stays alive under the others, so
  /// what it loaded may be old by the time it shows again.
  Future<void> _refresh() =>
      context.read<ResultsViewModel>().doAction(const RefreshResultsEvent());

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
      // Asked again as a notification arrives (a result published), the
      // app comes back, or the tab shows again; pulling down asks too.
      child: PageRefresher(
        path: AppRoutes.results,
        onRefresh: _refresh,
        child: ParentTabPage(
          title: context.l10n.results,
          selectedChild: context.watchSelectedChildIndex(),
          onChildSelected: (index) =>
              context.selectChild(children[index].studentId),
          onRefresh: _refresh,
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
      ),
    );
  }

  Widget _results(BuildContext context) {
    final state = context.watch<ResultsViewModel>().state;
    final child = context.select(
      (ChildrenViewModel viewModel) => viewModel.state.selectedChild,
    );
    final results = state.results;

    switch (results.state) {
      case StateType.initial || StateType.loading || StateType.moreLoading:
        return const ResultsSkeleton();
      case StateType.error:
        final exception = results.exception!;
        return StateMessage(
          icon: AppIcons.navResults,
          title: exception.localizedMessage(context),
          action: RetryOrLogInButton(
            exception: exception,
            onRetry: _loadResults,
          ),
        );
      case StateType.success:
        break;
    }

    final all = results.data ?? const [];
    final selected = state.selected;
    if (selected == null) {
      return StateMessage(
        icon: AppIcons.navResults,
        title: context.l10n.noResultsYet,
      );
    }
    // A month's: the year's certificate, with every month so far.
    final certificate = selected.isMonthly && child != null
        ? child.certificateWith(state.certificateMonths)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 18.h,
      children: [
        if (all.length > 1)
          ResultFilter(
            results: all,
            selectedId: selected.id,
            onSelected: (id) => context.read<ResultsViewModel>().doAction(
              SelectResultEvent(id),
            ),
          ),
        ResultDetailsView(
          key: ValueKey(selected.id),
          result: selected,
          certificate: certificate,
        ),
      ],
    );
  }
}
