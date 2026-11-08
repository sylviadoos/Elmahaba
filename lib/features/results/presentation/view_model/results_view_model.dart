import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/results/domain/use_cases/get_latest_result_use_case.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_event.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_state.dart';

/// The selected child's latest result on Results. One per Results page. No
/// navigation actions, hence `void`.
@injectable
class ResultsViewModel extends BaseCubit<ResultsState, ResultsEvent, void> {
  ResultsViewModel(this._getLatestResult) : super(const BaseState.initial());

  final GetLatestResultUseCase _getLatestResult;

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
      success: (latest) => emit(BaseState.success(latest)),
      failure: (exception) => emit(BaseState.error(exception)),
    );
  }
}
