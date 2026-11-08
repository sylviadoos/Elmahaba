import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/home/domain/use_cases/get_latest_announcements_use_case.dart';
import 'package:al_mahhaba_school/features/home/domain/use_cases/get_latest_homework_use_case.dart';
import 'package:al_mahhaba_school/features/home/domain/use_cases/get_latest_results_use_case.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/latest_updates_intent.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/latest_updates_state.dart';

/// Home's latest announcements, homework and results for the child picked
/// there. The three load side by side, each showing as soon as it comes.
/// One per Home. No one-off effects, hence a plain [Bloc].
@injectable
class LatestUpdatesBloc extends Bloc<LatestUpdatesIntent, LatestUpdatesState> {
  LatestUpdatesBloc(this._getAnnouncements, this._getHomework, this._getResults)
    : super(const LatestUpdatesState()) {
    on<ShowChildUpdatesIntent>(_onShowChild);
    on<RetryUpdatesIntent>(_onRetry);
  }

  final GetLatestAnnouncementsUseCase _getAnnouncements;
  final GetLatestHomeworkUseCase _getHomework;
  final GetLatestResultsUseCase _getResults;

  Future<void> _onShowChild(
    ShowChildUpdatesIntent intent,
    Emitter<LatestUpdatesState> emit,
  ) async {
    final childId = intent.childId;
    if (childId == state.childId) return _onRetry(intent, emit);
    // Another child: theirs replaces what's shown, all three at once.
    emit(
      LatestUpdatesState(
        childId: childId,
        announcements: const BaseState.loading(),
        homework: const BaseState.loading(),
        results: const BaseState.loading(),
      ),
    );
    await Future.wait([
      _loadAnnouncements(childId, emit),
      _loadHomework(childId, emit),
      _loadResults(childId, emit),
    ]);
  }

  /// Loads again only the parts that failed.
  Future<void> _onRetry(
    LatestUpdatesIntent intent,
    Emitter<LatestUpdatesState> emit,
  ) async {
    final childId = state.childId;
    if (childId == null || !state.hasFailure) return;
    bool failed(BaseState<Object?> part) => part.state == StateType.error;
    final announcements = failed(state.announcements);
    final homework = failed(state.homework);
    final results = failed(state.results);
    emit(
      state.copyWith(
        announcements: announcements ? const BaseState.loading() : null,
        homework: homework ? const BaseState.loading() : null,
        results: results ? const BaseState.loading() : null,
      ),
    );
    await Future.wait([
      if (announcements) _loadAnnouncements(childId, emit),
      if (homework) _loadHomework(childId, emit),
      if (results) _loadResults(childId, emit),
    ]);
  }

  Future<void> _loadAnnouncements(
    int childId,
    Emitter<LatestUpdatesState> emit,
  ) async {
    final result = await _getAnnouncements(childId);
    // Another child was picked meanwhile: theirs is on its way.
    if (state.childId != childId) return;
    emit(state.copyWith(announcements: _toState(result)));
  }

  Future<void> _loadHomework(
    int childId,
    Emitter<LatestUpdatesState> emit,
  ) async {
    final result = await _getHomework(childId);
    if (state.childId != childId) return;
    emit(state.copyWith(homework: _toState(result)));
  }

  Future<void> _loadResults(
    int childId,
    Emitter<LatestUpdatesState> emit,
  ) async {
    final result = await _getResults(childId);
    if (state.childId != childId) return;
    emit(state.copyWith(results: _toState(result)));
  }

  static BaseState<T> _toState<T>(Result<T> result) =>
      result.when(success: BaseState<T>.success, failure: BaseState<T>.error);
}
