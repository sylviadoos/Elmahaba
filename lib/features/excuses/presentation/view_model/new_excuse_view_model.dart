import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_details_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/use_cases/submit_excuse_use_case.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/new_excuse_event.dart';

/// Sending; on success, the excuse as the school has it.
typedef NewExcuseState = BaseState<ExcuseDetailsEntity>;

/// Sends a medical excuse. One per page. The page leaves itself once it's
/// sent, hence `void`.
@injectable
class NewExcuseViewModel
    extends BaseCubit<NewExcuseState, NewExcuseEvent, void> {
  NewExcuseViewModel(this._submitExcuse) : super(const BaseState.initial());

  final SubmitExcuseUseCase _submitExcuse;

  @override
  Future<void> doAction(NewExcuseEvent event) async {
    switch (event) {
      case SubmitExcuseEvent(:final childId, :final excuse):
        if (state.state == StateType.loading) return;
        emit(const BaseState.loading());
        final result = await _submitExcuse(childId, excuse);
        if (isClosed) return;
        emit(result.when(success: BaseState.success, failure: BaseState.error));
    }
  }
}
