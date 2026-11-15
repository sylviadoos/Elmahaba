import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/resend_child_link_code_use_case.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/verify_child_link_use_case.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/link_child_code_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/link_child_code_state.dart';

/// The code the school texted to the child's phone, on its page: checked
/// (the child is linked), or asked for again. One per page. No navigation
/// actions, hence `void`; the page reacts to the state.
@injectable
class LinkChildCodeViewModel
    extends BaseCubit<LinkChildCodeState, LinkChildCodeEvent, void> {
  LinkChildCodeViewModel(this._verifyChildLink, this._resendCode)
    : super(const LinkChildCodeState());

  final VerifyChildLinkUseCase _verifyChildLink;
  final ResendChildLinkCodeUseCase _resendCode;

  @override
  Future<void> doAction(LinkChildCodeEvent event) async {
    // One at a time: a code checked while another is on its way would
    // count as a wrong try.
    if (state.isBusy) return;
    switch (event) {
      case CheckLinkCodeEvent(:final token, :final code):
        await _check(token, code);
      case ResendLinkCodeEvent(:final token):
        await _resend(token);
    }
  }

  Future<void> _check(String token, String code) async {
    emit(state.copyWith(checking: const BaseState.loading()));
    final result = await _verifyChildLink(token: token, code: code);
    if (isClosed) return;
    result.when(
      success: (child) =>
          emit(state.copyWith(checking: BaseState.success(child))),
      failure: (exception) =>
          emit(state.copyWith(checking: BaseState.error(exception))),
    );
  }

  Future<void> _resend(String token) async {
    emit(state.copyWith(resending: const BaseState.loading()));
    final result = await _resendCode(token);
    if (isClosed) return;
    result.when(
      success: (verification) =>
          emit(state.copyWith(resending: BaseState.success(verification))),
      failure: (exception) =>
          emit(state.copyWith(resending: BaseState.error(exception))),
    );
  }
}
