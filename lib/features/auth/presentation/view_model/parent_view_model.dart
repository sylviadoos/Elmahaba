import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/get_saved_parent_use_case.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_event.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_state.dart';

/// The signed-in parent for the whole app: one instance, provided above the
/// router (see `app.dart`), so the Home and Profile headers show the same
/// name. No navigation actions, hence `void`.
@injectable
class ParentViewModel extends BaseCubit<ParentState, ParentEvent, void> {
  ParentViewModel(this._getSavedParent) : super(const BaseState.initial());

  final GetSavedParentUseCase _getSavedParent;

  @override
  Future<void> doAction(ParentEvent event) async {
    switch (event) {
      case ShowSavedParentEvent():
        final parent = await _getSavedParent();
        if (isClosed) return;
        emit(
          parent == null
              ? const BaseState.initial()
              : BaseState.success(parent),
        );
      case ClearParentEvent():
        emit(const BaseState.initial());
    }
  }
}
