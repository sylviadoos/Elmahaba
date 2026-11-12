import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/fees/domain/use_cases/change_optional_fee_use_case.dart';
import 'package:al_mahhaba_school/features/fees/domain/use_cases/get_fee_statement_use_case.dart';
import 'package:al_mahhaba_school/features/fees/presentation/view_model/fees_event.dart';
import 'package:al_mahhaba_school/features/fees/presentation/view_model/fees_state.dart';

/// The selected child's fee statement on Fees, and the optional fees the
/// parent adds to it or drops. One per Fees page. No navigation actions,
/// hence `void`.
@injectable
class FeesViewModel extends BaseCubit<FeesState, FeesEvent, void> {
  FeesViewModel(this._getFeeStatement, this._changeOptionalFee)
    : super(const FeesState());

  final GetFeeStatementUseCase _getFeeStatement;
  final ChangeOptionalFeeUseCase _changeOptionalFee;

  /// The child whose statement is shown or loading.
  int? _childId;

  @override
  Future<void> doAction(FeesEvent event) async {
    switch (event) {
      case LoadFeesEvent(:final childId, :final refresh):
        await _load(childId, refresh: refresh);
      case ChangeOptionalFeeEvent():
        await _changeOptional(event);
    }
  }

  Future<void> _load(int childId, {required bool refresh}) async {
    if (!refresh &&
        childId == _childId &&
        state.statement.state != StateType.error) {
      return;
    }
    _childId = childId;
    emit(const FeesState(statement: BaseState.loading()));
    final result = await _getFeeStatement(childId);
    // Another child was picked meanwhile: that one's on its way.
    if (isClosed || childId != _childId) return;
    result.when(
      success: (statement) =>
          emit(state.copyWith(statement: BaseState.success(statement))),
      failure: (exception) =>
          emit(state.copyWith(statement: BaseState.error(exception))),
    );
  }

  /// Asks the school to add the optional fee or drop it, then loads the
  /// statement again: the fee moves between the mandatory and optional
  /// lines, and the totals and installments change with it.
  Future<void> _changeOptional(ChangeOptionalFeeEvent event) async {
    if (state.isChanging) return;
    emit(
      state.copyWith(
        changingFeeId: () => event.feeId,
        changeFailed: () => null,
      ),
    );
    final result = await _changeOptionalFee(
      childId: event.childId,
      feeId: event.feeId,
      add: event.add,
    );
    if (isClosed) return;
    emit(state.copyWith(changingFeeId: () => null));
    await result.when(
      success: (_) => _load(event.childId, refresh: true),
      failure: (exception) async =>
          emit(state.copyWith(changeFailed: () => exception)),
    );
  }
}
