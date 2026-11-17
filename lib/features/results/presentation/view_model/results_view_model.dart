import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/results/domain/use_cases/get_results_use_case.dart';
import 'package:al_mahhaba_school/features/results/domain/use_cases/mark_latest_result_read_use_case.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_event.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_state.dart';

/// The selected child's results on Results: the newest shown first, any
/// other picked in the filter. One per Results page. No navigation
/// actions, hence `void`.
@injectable
class ResultsViewModel extends BaseCubit<ResultsState, ResultsEvent, void> {
  ResultsViewModel(this._getResults, this._markLatestRead)
    : super(const ResultsState());

  final GetResultsUseCase _getResults;

  /// A result stops being new on Home once the parent has it on screen.
  final MarkLatestResultReadUseCase _markLatestRead;

  @override
  Future<void> doAction(ResultsEvent event) async {
    switch (event) {
      case LoadResultsEvent(:final childId):
        await _load(childId);
      case RefreshResultsEvent():
        await _refresh();
      case SelectResultEvent(:final resultId):
        emit(state.copyWith(selectedId: resultId));
    }
  }

  /// Asked again while the results were on their way: that answer went out
  /// before whatever asked for them again (a result published, the parent
  /// pulling down on the skeleton), so it may be from before it. They're
  /// asked for once more as soon as it lands — once, however many asked.
  bool _askAgain = false;

  Future<void> _load(int childId) async {
    if (childId == state.childId && state.results.state != StateType.error) {
      return;
    }
    // Anything asked for while the child before was loading was about
    // them, not this one: it would spend a whole request on the wrong
    // answer. The load below is newer than any of it.
    _askAgain = false;
    // Another child, or again: the newest shown first.
    emit(ResultsState(childId: childId, results: const BaseState.loading()));
    final result = await _getResults(childId);
    // Another child was picked meanwhile: theirs is on its way.
    if (isClosed || state.childId != childId) return;
    result.when(
      success: (results) {
        emit(state.copyWith(results: BaseState.success(results)));
        final newest = results.firstOrNull?.id;
        if (newest != null) unawaited(_markSeen(childId, newest));
      },
      failure: (exception) =>
          emit(state.copyWith(results: BaseState.error(exception))),
    );
    // Asked for while this was on its way: now it can be answered. Not
    // waited on, so what asked for the load isn't held up by it.
    if (_askAgain && !isClosed) {
      _askAgain = false;
      unawaited(_refresh());
    }
  }

  /// One refresh at a time.
  bool _refreshing = false;

  Future<void> _refresh() async {
    final childId = state.childId;
    if (childId == null) return;
    // Didn't load: as "Try again".
    if (state.results.state == StateType.error) return _load(childId);
    // Loading already: asked again once it's here. A refresh in flight is
    // not: its answer is newer than what asked for this one.
    if (state.results.state == StateType.loading) {
      _askAgain = true;
      return;
    }
    final shown = state.results.data;
    if (state.results.state != StateType.success ||
        shown == null ||
        _refreshing) {
      return;
    }
    _refreshing = true;
    final result = await _getResults(childId);
    _refreshing = false;
    // Another child was picked meanwhile: theirs is on its way.
    if (isClosed || state.childId != childId) return;
    result.when(
      success: (results) {
        final newest = results.firstOrNull?.id;
        // One the parent hasn't been shown before — not merely a different
        // newest: when the school withdraws the newest, the one under it
        // takes its place, and that is not something published.
        final published =
            newest != null && !shown.any((result) => result.id == newest);
        emit(
          ResultsState(
            childId: childId,
            results: BaseState.success(results),
            // A new one: it shows, as when Results opens. Else the one
            // picked stays (the newest when it's gone).
            selectedId: published ? null : state.selectedId,
          ),
        );
        if (published) unawaited(_markSeen(childId, newest));
      },
      // Only a refresh: what's shown stays, the next one tries again.
      failure: (exception) => debugPrint('Refreshing results: $exception'),
    );
  }

  /// The newest result already reported seen, by child. Telling the school
  /// costs a whole dashboard request (it is the only place that says
  /// whether the result is still new), so it is told once per result —
  /// not again when Results is opened for that child a second time, nor
  /// when the newest changes for another reason, such as one withdrawn at
  /// school.
  final _reportedSeen = <int, int>{};

  /// The newest is on screen: Home reloads itself once the school confirms
  /// (`WatchChatReadsUseCase`). [latestId] is the result it is about.
  Future<void> _markSeen(int childId, int latestId) async {
    // Reported already, or being reported right now.
    if (_reportedSeen[childId] == latestId) return;
    _reportedSeen[childId] = latestId;
    final result = await _markLatestRead(childId);
    result.when(
      success: (_) {},
      failure: (exception) {
        // Not reported after all: tried again the next time Results loads
        // for this child.
        if (_reportedSeen[childId] == latestId) _reportedSeen.remove(childId);
        debugPrint('Marking the result read: $exception');
      },
    );
  }
}
