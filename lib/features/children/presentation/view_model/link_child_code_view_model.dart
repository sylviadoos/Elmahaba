import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/domain/school_sms_down.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_proof_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/verify_otp_use_case.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_verification_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/resend_child_link_code_use_case.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/send_child_link_code_use_case.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/verify_child_link_use_case.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/link_child_code_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/link_child_code_state.dart';

/// The code sent to the school's phone for the child, on its page: sent by
/// the school (SMS Misr) or Firebase — whichever goes first
/// (`AppConfig.smsMisrFirst`), the other when it fails; checked (the child
/// is linked), or asked for again. One per page. No navigation actions,
/// hence `void`; the page reacts to the state.
@injectable
class LinkChildCodeViewModel
    extends BaseCubit<LinkChildCodeState, LinkChildCodeEvent, void> {
  LinkChildCodeViewModel(
    this._verifyChildLink,
    this._sendByFirebase,
    this._textBySchool,
    this._checkFirebaseCode,
    @Named(AppConfig.smsMisrFirstName) this._smsMisrFirst,
  ) : super(const LinkChildCodeState());

  final VerifyChildLinkUseCase _verifyChildLink;
  final SendChildLinkCodeUseCase _sendByFirebase;
  final ResendChildLinkCodeUseCase _textBySchool;

  /// Checks a code Firebase sent; gives its proof of the number.
  final VerifyOtpUseCase _checkFirebaseCode;

  /// Whether the school texts the code first, Firebase only when it fails.
  final bool _smsMisrFirst;

  /// From the last code Firebase sent: checks the typed code, and sends it
  /// again.
  String? _verificationId;
  int? _resendToken;

  /// Whether the school texts the codes: it gave no number for Firebase, or
  /// Firebase couldn't send one.
  bool _bySchool = false;

  @override
  Future<void> doAction(LinkChildCodeEvent event) async {
    // One at a time: a code checked while another is on its way would
    // count as a wrong try.
    if (state.isBusy) return;
    switch (event) {
      case CheckLinkCodeEvent(:final token, :final code):
        await _check(token, code);
      case SendLinkCodeEvent(:final verification):
        await _send(verification);
    }
  }

  Future<void> _check(String token, String code) async {
    emit(state.copyWith(checking: const BaseState.loading()));
    final verificationId = _verificationId;
    // The school's code goes as it is: the school checks it.
    if (_bySchool || verificationId == null) {
      return _link(token, SchoolCodeProof(code));
    }
    final checked = await _checkFirebaseCode(
      verificationId: verificationId,
      smsCode: code,
    );
    if (isClosed) return;
    switch (checked) {
      case Success(:final data):
        await _link(token, FirebaseProof(data));
      case Failure(:final exception):
        emit(state.copyWith(checking: BaseState.error(exception)));
    }
  }

  Future<void> _link(String token, PhoneProofEntity proof) async {
    emit(state.copyWith(checking: const BaseState.loading()));
    final result = await _verifyChildLink(token: token, proof: proof);
    if (isClosed) return;
    result.when(
      success: (child) =>
          emit(state.copyWith(checking: BaseState.success(child))),
      failure: (exception) =>
          emit(state.copyWith(checking: BaseState.error(exception))),
    );
  }

  Future<void> _send(LinkVerificationEntity verification) async {
    emit(state.copyWith(resending: const BaseState.loading()));
    final phone = verification.phone;
    // The school texts it: first, or with no number for Firebase, or after
    // a code of its own — or Firebase sent one already and the parent asks
    // again, so it didn't come (Firebase can say it sent one that never
    // arrives).
    if (_smsMisrFirst ||
        _bySchool ||
        phone == null ||
        _verificationId != null) {
      final failure = await _sendBySchool(verification.token);
      if (failure == null || isClosed) return;
      // SMS Misr failed and the school goes first: Firebase sends it.
      if (_smsMisrFirst && phone != null && failure.isSchoolSmsDown) {
        debugPrint(
          'The school sent no linking code ($failure): Firebase sends one.',
        );
        return _sendByFirebaseOr(verification, phone, onFailure: null);
      }
      emit(state.copyWith(resending: BaseState.error(failure)));
      return;
    }
    await _sendByFirebaseOr(
      verification,
      phone,
      // Firebase couldn't send it (blocked, out of quota, set up wrong…):
      // the school texts it instead, and the next ones too.
      onFailure: (exception) async {
        debugPrint(
          'Firebase sent no linking code ($exception): the school '
          'sends one.',
        );
        final failure = await _sendBySchool(verification.token);
        if (failure != null && !isClosed) {
          emit(state.copyWith(resending: BaseState.error(failure)));
        }
      },
    );
  }

  /// Has Firebase send the code to [phone]. When it fails: [onFailure], or
  /// its error with none.
  Future<void> _sendByFirebaseOr(
    LinkVerificationEntity verification,
    String phone, {
    required Future<void> Function(AppException exception)? onFailure,
  }) async {
    final sent = await _sendByFirebase(phone, resendToken: _resendToken);
    if (isClosed) return;
    switch (sent) {
      case Success(
        data: SmsCodeSent(:final verificationId, :final resendToken),
      ):
        _verificationId = verificationId;
        _resendToken = resendToken;
        // Firebase's: Firebase checks it.
        _bySchool = false;
        emit(state.copyWith(resending: BaseState.success(verification)));
      // Android verified the number by itself: linked at once.
      case Success(data: PhoneAutoVerified(:final firebaseIdToken)):
        emit(state.copyWith(resending: const BaseState.initial()));
        await _link(verification.token, FirebaseProof(firebaseIdToken));
      case Success():
        emit(state.copyWith(resending: BaseState.success(verification)));
      case Failure(:final exception):
        if (onFailure != null) return onFailure(exception);
        emit(state.copyWith(resending: BaseState.error(exception)));
    }
  }

  /// Has the school text the code; null once it has, else why not (not
  /// emitted: the caller decides). Once the school has texted a code, it's
  /// the one the parent types: checked by the school, not Firebase. Until
  /// then (it failed) a late Firebase code still counts.
  Future<AppException?> _sendBySchool(String token) async {
    final result = await _textBySchool(token);
    if (isClosed) return null;
    switch (result) {
      case Success(:final data):
        _bySchool = true;
        emit(state.copyWith(resending: BaseState.success(data)));
        return null;
      case Failure(:final exception):
        return exception;
    }
  }
}
