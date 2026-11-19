import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_proof_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/verify_otp_use_case.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_verification_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/resend_child_link_code_use_case.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/send_child_link_code_use_case.dart';
import 'package:al_mahhaba_school/features/children/domain/use_cases/verify_child_link_use_case.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/link_child_code_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/link_child_code_state.dart';

/// Who sent the code the parent is waiting for.
enum _Sender { none, firebase, school }

/// The code sent to the school's phone for the child, on its page. The
/// school takes either kind with the same `verification_token` for its 5
/// minutes, and links the child with the first that's right:
/// - The first, when the school gave its number (`verification.phone`):
///   the school texts it (SMS Misr, `resend-otp`) when it sends first
///   (`AppConfig.smsMisrFirst`), Firebase only if it can't; otherwise
///   Firebase sends it, the school at once if Firebase can't.
/// - "Didn't get it" takes turns: after Firebase's, the school texts one;
///   after the school's, Firebase sends one again. Each says it sent a code
///   that may never arrive, so asking again tries the other way.
/// - The code typed is checked as the last one came: Firebase's gives its
///   `firebase_id_token`, the school's goes as `code`.
///
/// One per page. No navigation actions, hence `void`; the page reacts to
/// the state.
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

  /// Whether the school texts the first code (`AppConfig.smsMisrFirst`),
  /// Firebase only when it can't.
  final bool _smsMisrFirst;

  final VerifyChildLinkUseCase _verifyChildLink;
  final SendChildLinkCodeUseCase _sendByFirebase;
  final ResendChildLinkCodeUseCase _textBySchool;

  /// Checks a code Firebase sent; gives its proof of the number.
  final VerifyOtpUseCase _checkFirebaseCode;

  /// From the last code Firebase sent: checks the typed code, and sends it
  /// again.
  String? _verificationId;
  int? _resendToken;

  /// Who sent the last code that went: the typed code is checked that way,
  /// and asking again goes the other way.
  _Sender _last = _Sender.none;

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
    if (_last != _Sender.firebase || verificationId == null) {
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
    // The school texts it: without a number for Firebase, after Firebase's,
    // or first when the school sends first. Else Firebase: first, or after
    // the school's.
    final first = _last == _Sender.none;
    if (phone == null || _last == _Sender.firebase) {
      final failure = await _sendBySchool(verification);
      if (failure != null && !isClosed) {
        emit(state.copyWith(resending: BaseState.error(failure)));
      }
      return;
    }
    final bySchool = first && _smsMisrFirst;
    if (bySchool) {
      final failure = await _sendBySchool(verification);
      if (failure == null || isClosed) return;
      // The school's first text didn't go: Firebase sends it instead.
      debugPrint(
        'The school sent no linking code ($failure): Firebase sends one.',
      );
    }
    final sent = await _sendByFirebase(phone, resendToken: _resendToken);
    if (isClosed) return;
    switch (sent) {
      case Success(
        data: SmsCodeSent(:final verificationId, :final resendToken),
      ):
        _verificationId = verificationId;
        _resendToken = resendToken;
        _last = _Sender.firebase;
        emit(
          state.copyWith(
            resending: BaseState.success(verification),
            // Asked again: the school texts one.
            nextByFirebase: false,
          ),
        );
      // Android verified the number by itself: linked at once.
      case Success(data: PhoneAutoVerified(:final firebaseIdToken)):
        emit(state.copyWith(resending: const BaseState.initial()));
        await _link(verification.token, FirebaseProof(firebaseIdToken));
      case Success():
        emit(state.copyWith(resending: BaseState.success(verification)));
      // Firebase couldn't either, after the school: its error.
      case Failure(:final exception) when bySchool:
        emit(state.copyWith(resending: BaseState.error(exception)));
      // Firebase couldn't send it (blocked, out of quota, set up wrong…):
      // the school texts it at once, without waiting for "Didn't get it".
      case Failure(:final exception):
        debugPrint(
          'Firebase sent no linking code ($exception): the school sends one.',
        );
        final failure = await _sendBySchool(verification);
        if (failure != null && !isClosed) {
          emit(state.copyWith(resending: BaseState.error(failure)));
        }
    }
  }

  /// Has the school text the code; null once it has, else why not (not
  /// emitted: the caller decides). Once the school has texted a code, it's
  /// the one the parent types: checked by the school. Until then (it
  /// failed) the last code — Firebase's — still counts.
  Future<AppException?> _sendBySchool(
    LinkVerificationEntity verification,
  ) async {
    final result = await _textBySchool(verification.token);
    if (isClosed) return null;
    switch (result) {
      case Success(:final data):
        _last = _Sender.school;
        emit(
          state.copyWith(
            resending: BaseState.success(data),
            // Asked again: Firebase sends one, when there's a number for it
            // — not counted against the school's resends.
            nextByFirebase: verification.phone != null,
          ),
        );
        return null;
      case Failure(:final exception):
        return exception;
    }
  }
}
