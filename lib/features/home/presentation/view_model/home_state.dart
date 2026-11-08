import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';

class HomeState extends Equatable {
  const HomeState({this.dashboard = const BaseState.initial()});

  /// The selected child's dashboard.
  final BaseState<ChildDashboardEntity> dashboard;

  HomeState copyWith({BaseState<ChildDashboardEntity>? dashboard}) =>
      HomeState(dashboard: dashboard ?? this.dashboard);

  @override
  List<Object?> get props => [dashboard];
}
