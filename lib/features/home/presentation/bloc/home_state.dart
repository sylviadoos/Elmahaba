import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';

/// Home: the dashboard of the child shown.
class HomeState extends Equatable {
  const HomeState({
    this.childId,
    this.dashboard = const BaseState.initial(),
    this.isRefreshing = false,
  });

  /// The child shown, by `studentId`; null before the children load.
  final int? childId;

  /// Loading (the skeleton) only for a child not shown yet; a refresh keeps
  /// the one shown.
  final BaseState<ChildDashboardEntity> dashboard;

  /// Asking the school again while the dashboard stays shown.
  final bool isRefreshing;

  HomeState copyWith({
    int? childId,
    BaseState<ChildDashboardEntity>? dashboard,
    bool? isRefreshing,
  }) => HomeState(
    childId: childId ?? this.childId,
    dashboard: dashboard ?? this.dashboard,
    isRefreshing: isRefreshing ?? this.isRefreshing,
  );

  @override
  List<Object?> get props => [childId, dashboard, isRefreshing];
}
