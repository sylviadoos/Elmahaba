import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/watch_chat_reads_use_case.dart';
import 'package:al_mahhaba_school/features/home/domain/use_cases/get_child_dashboard_use_case.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/home_intent.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/home_state.dart';

/// Home (MVI): everything for the child shown comes from one dashboard
/// call, asked again whenever something may have changed — never on a
/// timer. That includes the school confirming items were read (the chat,
/// announcements, homework), even with Home underneath: back on it, the
/// counts are right. One per Home. No one-off effects, hence a plain
/// [Bloc].
@injectable
class HomeBloc extends Bloc<HomeIntent, HomeState> {
  HomeBloc(this._getChildDashboard, WatchChatReadsUseCase watchReads)
    : super(const HomeState()) {
    on<ShowChildIntent>(_onShowChild);
    on<RefreshHomeIntent>(_onRefresh);
    _reads = watchReads().listen((_) => add(const RefreshHomeIntent()));
  }

  final GetChildDashboardUseCase _getChildDashboard;
  late final StreamSubscription<int> _reads;

  /// Asked to refresh while the dashboard was on its way: that answer may
  /// be from before the change (the chat's read and Home's refresh go
  /// together when leaving it), so it's asked once more after.
  bool _askAgain = false;

  @override
  Future<void> close() async {
    await _reads.cancel();
    return super.close();
  }

  Future<void> _onShowChild(
    ShowChildIntent intent,
    Emitter<HomeState> emit,
  ) async {
    final childId = intent.childId;
    if (childId == state.childId && state.dashboard.state != StateType.error) {
      return;
    }
    // Another child (or theirs failed): the skeleton until it comes.
    emit(HomeState(childId: childId, dashboard: const BaseState.loading()));
    await _load(childId, emit);
  }

  Future<void> _onRefresh(
    RefreshHomeIntent intent,
    Emitter<HomeState> emit,
  ) async {
    final childId = state.childId;
    if (childId == null) return;
    switch (state.dashboard.state) {
      case StateType.initial:
        return;
      // Loading already: asked again once it's here.
      case StateType.loading || StateType.moreLoading:
        _askAgain = true;
        return;
      // "Try again".
      case StateType.error:
        emit(state.copyWith(dashboard: const BaseState.loading()));
      case StateType.success:
        if (state.isRefreshing) {
          _askAgain = true;
          return;
        }
        emit(state.copyWith(isRefreshing: true));
    }
    await _load(childId, emit);
  }

  Future<void> _load(int childId, Emitter<HomeState> emit) async {
    final result = await _getChildDashboard(childId);
    // Another child was picked meanwhile: theirs is on its way.
    if (state.childId != childId) return;
    final shown = state.dashboard.data;
    result.when(
      success: (dashboard) => emit(
        state.copyWith(
          dashboard: BaseState.success(dashboard),
          isRefreshing: false,
        ),
      ),
      failure: (exception) {
        if (shown == null) {
          emit(
            state.copyWith(
              dashboard: BaseState.error(exception),
              isRefreshing: false,
            ),
          );
          return;
        }
        // Only a refresh: what's shown stays, the next one tries again.
        debugPrint('Home refresh: $exception');
        emit(state.copyWith(isRefreshing: false));
      },
    );
    if (_askAgain && !isClosed) {
      _askAgain = false;
      add(const RefreshHomeIntent());
    }
  }
}
