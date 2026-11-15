import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/fees/domain/use_cases/pay_online_use_case.dart';
import 'package:al_mahhaba_school/features/fees/presentation/view_model/pay_fees_event.dart';
import 'package:al_mahhaba_school/features/fees/presentation/view_model/pay_fees_state.dart';

/// Paying fees online on Pay fees. One per Pay fees page. The page opens
/// the payment page itself (on success), hence `void`.
@injectable
class PayFeesViewModel extends BaseCubit<PayFeesState, PayFeesEvent, void> {
  PayFeesViewModel(this._payOnline) : super(const BaseState.initial());

  final PayOnlineUseCase _payOnline;

  @override
  Future<void> doAction(PayFeesEvent event) async {
    switch (event) {
      case PayOnlineEvent(:final childId, :final payKeys):
        await _pay(childId, payKeys);
    }
  }

  Future<void> _pay(int childId, List<String> payKeys) async {
    if (state.state == StateType.loading) return;
    emit(const BaseState.loading());
    final result = await _payOnline(childId: childId, payKeys: payKeys);
    if (isClosed) return;
    result.when(
      success: (checkout) => emit(BaseState.success(checkout)),
      failure: (exception) => emit(BaseState.error(exception)),
    );
  }
}
