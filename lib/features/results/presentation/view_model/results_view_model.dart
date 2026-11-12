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
      case SelectResultEvent(:final resultId):
        emit(state.copyWith(selectedId: resultId));
    }
  }

  Future<void> _load(int childId) async {
    if (childId == state.childId && state.results.state != StateType.error) {
      return;
    }
    // Another child, or again: the newest shown first.
    emit(ResultsState(childId: childId, results: const BaseState.loading()));
    final result = await _getResults(childId);
    // Another child was picked meanwhile: theirs is on its way.
    if (isClosed || state.childId != childId) return;
    result.when(
      success: (results) {
        emit(state.copyWith(results: BaseState.success(results)));
        if (results.isNotEmpty) unawaited(_markSeen(childId));
      },
      failure: (exception) =>
          emit(state.copyWith(results: BaseState.error(exception))),
    );
  }

  /// The newest is on screen: Home reloads itself once the school confirms
  /// (`WatchChatReadsUseCase`).
  Future<void> _markSeen(int childId) async {
    final result = await _markLatestRead(childId);
    result.when(
      success: (_) {},
      // Tried again the next time Results is opened.
      failure: (exception) => debugPrint('Marking the result read: $exception'),
    );
  }
}
