import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/results/domain/use_cases/get_monthly_results_use_case.dart';
import 'package:al_mahhaba_school/features/results/presentation/bloc/monthly_results_intent.dart';
import 'package:al_mahhaba_school/features/results/presentation/bloc/monthly_results_state.dart';

/// The selected child's monthly results on Results (MVI): the months the
/// school published, one shown at a time. One per Results page. No
/// one-off effects, hence a plain [Bloc].
@injectable
class MonthlyResultsBloc
    extends Bloc<MonthlyResultsIntent, MonthlyResultsState> {
  MonthlyResultsBloc(this._getMonthlyResults)
    : super(const MonthlyResultsState()) {
    on<ShowChildMonthlyIntent>(_onShowChild);
    on<SelectMonthIntent>(
      (intent, emit) => emit(state.copyWith(selectedKey: intent.key)),
    );
  }

  final GetMonthlyResultsUseCase _getMonthlyResults;

  Future<void> _onShowChild(
    ShowChildMonthlyIntent intent,
    Emitter<MonthlyResultsState> emit,
  ) async {
    final childId = intent.childId;
    if (childId == state.childId && state.results.state != StateType.error) {
      return;
    }
    emit(
      MonthlyResultsState(childId: childId, results: const BaseState.loading()),
    );
    final result = await _getMonthlyResults(childId);
    // Another child was picked meanwhile: theirs is on its way.
    if (state.childId != childId) return;
    result.when(
      success: (results) => emit(
        MonthlyResultsState(
          childId: childId,
          results: BaseState.success(results),
          // The newest month.
          selectedKey: results.certificate?.months.lastOrNull?.key,
        ),
      ),
      failure: (exception) =>
          emit(state.copyWith(results: BaseState.error(exception))),
    );
  }
}
