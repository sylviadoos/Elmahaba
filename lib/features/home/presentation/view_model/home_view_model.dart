import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/home/domain/use_cases/get_child_dashboard_use_case.dart';
import 'package:al_mahhaba_school/features/home/presentation/view_model/home_event.dart';
import 'package:al_mahhaba_school/features/home/presentation/view_model/home_state.dart';

/// The selected child's dashboard, on Home and under School chat's header.
/// One per page. No navigation actions, hence `void`.
@injectable
class HomeViewModel extends BaseCubit<HomeState, HomeEvent, void> {
  HomeViewModel(this._getChildDashboard) : super(const HomeState());

  final GetChildDashboardUseCase _getChildDashboard;

  /// The child whose dashboard is shown or loading.
  int? _childId;

  @override
  Future<void> doAction(HomeEvent event) async {
    switch (event) {
      case LoadDashboardEvent(:final childId):
        await _load(childId);
    }
  }

  Future<void> _load(int childId) async {
    if (childId == _childId && state.dashboard.state != StateType.error) {
      return;
    }
    _childId = childId;
    emit(state.copyWith(dashboard: const BaseState.loading()));
    final result = await _getChildDashboard(childId);
    // Another child was picked meanwhile: that one's on its way.
    if (isClosed || childId != _childId) return;
    result.when(
      success: (dashboard) =>
          emit(state.copyWith(dashboard: BaseState.success(dashboard))),
      failure: (exception) =>
          emit(state.copyWith(dashboard: BaseState.error(exception))),
    );
  }
}
