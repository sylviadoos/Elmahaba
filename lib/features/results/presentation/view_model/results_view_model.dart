import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/chat/domain/use_cases/mark_chat_read_use_case.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/results/domain/use_cases/get_latest_result_use_case.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_event.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_state.dart';

/// The selected child's latest result on Results. One per Results page. No
/// navigation actions, hence `void`.
@injectable
class ResultsViewModel extends BaseCubit<ResultsState, ResultsEvent, void> {
  ResultsViewModel(this._getLatestResult, this._markRead)
    : super(const BaseState.initial());

  final GetLatestResultUseCase _getLatestResult;

  /// A result stops being new once its chat item is read; showing it here
  /// counts, the same as reading it in the chat.
  final MarkChatReadUseCase _markRead;

  /// The child whose result is shown or loading.
  int? _childId;

  @override
  Future<void> doAction(ResultsEvent event) async {
    switch (event) {
      case LoadLatestResultEvent(:final childId):
        await _load(childId);
    }
  }

  Future<void> _load(int childId) async {
    if (childId == _childId && state.state != StateType.error) return;
    _childId = childId;
    emit(const BaseState.loading());
    final result = await _getLatestResult(childId);
    // Another child was picked meanwhile: that one's on its way.
    if (isClosed || childId != _childId) return;
    result.when(
      success: (latest) {
        emit(BaseState.success(latest?.details));
        if (latest != null) unawaited(_markSeen(latest));
      },
      failure: (exception) => emit(BaseState.error(exception)),
    );
  }

  /// Tells the school the parent has the result on screen, so Home stops
  /// calling it new. Home reloads itself once the school confirms
  /// (`WatchChatReadsUseCase`). Nothing to do for one already read, or one
  /// the school made no chat item for.
  Future<void> _markSeen(LatestResult latest) async {
    final chatKey = latest.chatKey;
    if (latest.isRead || chatKey == null) return;
    final result = await _markRead([chatKey]);
    result.when(
      success: (_) {},
      // Tried again the next time Results is opened.
      failure: (exception) => debugPrint('Marking the result read: $exception'),
    );
  }
}
