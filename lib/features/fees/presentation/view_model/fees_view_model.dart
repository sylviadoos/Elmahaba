import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/fees/domain/use_cases/get_fee_statement_use_case.dart';
import 'package:al_mahhaba_school/features/fees/presentation/view_model/fees_event.dart';
import 'package:al_mahhaba_school/features/fees/presentation/view_model/fees_state.dart';

/// The selected child's fee statement on Fees. One per Fees page. No
/// navigation actions, hence `void`.
@injectable
class FeesViewModel extends BaseCubit<FeesState, FeesEvent, void> {
  FeesViewModel(this._getFeeStatement) : super(const BaseState.initial());

  final GetFeeStatementUseCase _getFeeStatement;

  /// The child whose statement is shown or loading.
  int? _childId;

  @override
  Future<void> doAction(FeesEvent event) async {
    switch (event) {
      case LoadFeesEvent(:final childId, :final refresh):
        await _load(childId, refresh: refresh);
    }
  }

  Future<void> _load(int childId, {required bool refresh}) async {
    if (!refresh && childId == _childId && state.state != StateType.error) {
      return;
    }
    _childId = childId;
    emit(const BaseState.loading());
    final result = await _getFeeStatement(childId);
    // Another child was picked meanwhile: that one's on its way.
    if (isClosed || childId != _childId) return;
    result.when(
      success: (statement) => emit(BaseState.success(statement)),
      failure: (exception) => emit(BaseState.error(exception)),
    );
  }
}
