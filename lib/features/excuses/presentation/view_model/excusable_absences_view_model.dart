import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excusable_absences_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/use_cases/get_excusable_absences_use_case.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/excusable_absences_event.dart';

typedef ExcusableAbsencesState = BaseState<ExcusableAbsencesEntity>;

/// The selected child's absences an excuse can be sent for, under
/// Attendance's days. One per Attendance page. No navigation actions,
/// hence `void`.
@injectable
class ExcusableAbsencesViewModel
    extends BaseCubit<ExcusableAbsencesState, ExcusableAbsencesEvent, void> {
  ExcusableAbsencesViewModel(this._getAbsences)
    : super(const BaseState.initial());

  final GetExcusableAbsencesUseCase _getAbsences;

  /// The child whose absences are shown or loading.
  int? _childId;

  @override
  Future<void> doAction(ExcusableAbsencesEvent event) async {
    switch (event) {
      case LoadExcusableAbsencesEvent(:final childId):
        await _load(childId);
    }
  }

  Future<void> _load(int childId) async {
    final shown = childId == _childId ? state.data : null;
    _childId = childId;
    emit(BaseState.all(state: StateType.loading, data: shown, exception: null));
    final result = await _getAbsences(childId);
    // Another child was picked meanwhile: that one's on its way.
    if (isClosed || childId != _childId) return;
    result.when(
      success: (absences) => emit(BaseState.success(absences)),
      failure: (exception) => emit(
        BaseState.all(
          state: StateType.error,
          data: shown,
          exception: exception,
        ),
      ),
    );
  }
}
