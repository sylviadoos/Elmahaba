import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/month_attendance_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';

/// Home: the dashboard of the child shown.
class HomeState extends Equatable {
  const HomeState({
    this.childId,
    this.dashboard = const BaseState.initial(),
    this.isRefreshing = false,
    this.calendar,
  });

  /// The child shown, by `studentId`; null before the children load.
  final int? childId;

  /// Loading (the skeleton) only for a child not shown yet; a refresh keeps
  /// the one shown.
  final BaseState<ChildDashboardEntity> dashboard;

  /// Asking the school again while the dashboard stays shown.
  final bool isRefreshing;

  /// This month's attendance of the child shown, for whether today is a
  /// holiday or a day off; null until it comes, or when it didn't.
  final MonthAttendanceEntity? calendar;

  HomeState copyWith({
    int? childId,
    BaseState<ChildDashboardEntity>? dashboard,
    bool? isRefreshing,
    MonthAttendanceEntity? calendar,
  }) => HomeState(
    childId: childId ?? this.childId,
    dashboard: dashboard ?? this.dashboard,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    calendar: calendar ?? this.calendar,
  );

  @override
  List<Object?> get props => [childId, dashboard, isRefreshing, calendar];
}
