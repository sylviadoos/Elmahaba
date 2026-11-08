import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/get_child_details_use_case.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/child_details_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/child_details_state.dart';

/// One child's page: everything the school has on them. No navigation
/// actions, hence `void`.
@injectable
class ChildDetailsViewModel
    extends BaseCubit<ChildDetailsState, ChildDetailsEvent, void> {
  ChildDetailsViewModel(this._getDetails) : super(const ChildDetailsState());

  final GetChildDetailsUseCase _getDetails;

  @override
  Future<void> doAction(ChildDetailsEvent event) async {
    switch (event) {
      case LoadChildDetailsEvent(:final childId, :final refresh):
        await _load(childId, refresh: refresh);
    }
  }

  Future<void> _load(int childId, {required bool refresh}) async {
    if (state.details.state == StateType.loading) return;
    final shown = refresh ? state.details.data : null;
    if (shown == null) {
      emit(state.copyWith(details: const BaseState.loading()));
    }
    final result = await _getDetails(childId);
    if (isClosed) return;
    result.when(
      success: (details) =>
          emit(state.copyWith(details: BaseState.success(details))),
      failure: (exception) {
        // Refreshing: keep showing it.
        if (shown != null) return;
        emit(state.copyWith(details: BaseState.error(exception)));
      },
    );
  }
}
