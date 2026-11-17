import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/complete_register_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_proof_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/register_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/change_password_use_case.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/check_register_phone_use_case.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/complete_register_use_case.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/login_use_case.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/send_otp_use_case.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/verify_otp_use_case.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_event.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_state.dart';

/// Drives the auth pages (Log in, Register, OTP, Forgot and Change
/// password). Each page gets its own instance. No navigation actions,
/// hence `void`.
@injectable
class AuthViewModel extends BaseCubit<AuthState, AuthEvent, void> {
  AuthViewModel(
    this._checkPhone,
    this._login,
    this._sendOtp,
    this._verifyOtp,
    this._completeRegister,
    this._resetPassword,
    this._changePassword,
  ) : super(const AuthState.initial());

  final CheckRegisterPhoneUseCase _checkPhone;
  final LoginUseCase _login;
  final SendOtpUseCase _sendOtp;
  final VerifyOtpUseCase _verifyOtp;
  final CompleteRegisterUseCase _completeRegister;
  final ResetPasswordUseCase _resetPassword;
  final ChangePasswordUseCase _changePassword;

  /// From the last code Firebase sent: checks the typed code, and sends it
  /// again.
  String? _verificationId;
  int? _resendToken;

  /// Whether the school sent the last code (Firebase couldn't): its code
  /// isn't checked here, and the next one comes from the school too.
  bool _bySchool = false;

  @override
  Future<void> doAction(AuthEvent event) async {
    switch (event) {
      case CheckRegisterPhoneEvent(:final request):
        await _run(
          () async => (await _checkPhone(
            request,
          )).map((eligibility) => PhoneEligible(request, eligibility)),
        );
      case LoginEvent(:final request):
        await _run(() async => (await _login(request)).map(LoggedIn.new));
      case SendOtpEvent(:final request):
        await _run(
          () => _sendCode(
            request.phone,
            then: (token) => _register(request, token),
          ),
        );
      case VerifyOtpEvent(:final request, :final code):
        await _run(
          () => _checkCode(code, then: (token) => _register(request, token)),
        );
      case SendResetCodeEvent(:final phone):
        await _run(() => _sendCode(phone, then: _verified));
      case VerifyResetCodeEvent(:final code):
        await _run(() => _checkCode(code, then: _verified));
      case ResetPasswordEvent(:final request):
        await _run(
          () async =>
              (await _resetPassword(request)).map((_) => const PasswordReset()),
        );
      case ChangePasswordEvent(:final request):
        await _run(
          () async => (await _changePassword(
            request,
          )).map((_) => const PasswordChanged()),
        );
    }
  }

  /// Runs [call] (one at a time) and emits how it ended.
  Future<void> _run(Future<Result<AuthResult>> Function() call) async {
    if (state.state == StateType.loading) return;
    emit(const AuthState.loading());
    final result = await call();
    if (isClosed) return;
    emit(
      result.when(
        success: (data) => AuthState.success(data),
        failure: (exception) => AuthState.error(exception),
      ),
    );
  }

  /// Sends the SMS code to [phone]. If Android verifies the number by
  /// itself, goes straight on with [then] and Firebase's proof.
  Future<Result<AuthResult>> _sendCode(
    String phone, {
    required Future<Result<AuthResult>> Function(PhoneProofEntity proof) then,
  }) async {
    final sent = await _sendOtp(
      phone,
      resendToken: _resendToken,
      bySchool: _bySchool,
    );
    return sent.andThen((verification) async {
      switch (verification) {
        case SmsCodeSent(:final verificationId, :final resendToken):
          _verificationId = verificationId;
          _resendToken = resendToken;
          return const Success(data: OtpSent());
        case SchoolCodeSent(:final resendAfter):
          _bySchool = true;
          return Success(data: OtpSent(resendAfter: resendAfter));
        case PhoneAutoVerified(:final firebaseIdToken):
          return then(FirebaseProof(firebaseIdToken));
      }
    });
  }

  /// Checks the typed [code], then goes on with [then] and its proof. The
  /// school's code goes on unchecked: the school checks it with [then]'s
  /// request.
  Future<Result<AuthResult>> _checkCode(
    String code, {
    required Future<Result<AuthResult>> Function(PhoneProofEntity proof) then,
  }) async {
    if (_bySchool) return then(SchoolCodeProof(code));
    final verificationId = _verificationId;
    if (verificationId == null) {
      return const Failure(
        exception: PhoneVerificationException(code: AuthErrorCodes.noCodeSent),
      );
    }
    final verified = await _verifyOtp(
      verificationId: verificationId,
      smsCode: code,
    );
    return verified.andThen((token) => then(FirebaseProof(token)));
  }

  /// Forgot password: the number is verified; the new password comes next.
  static Future<Result<AuthResult>> _verified(PhoneProofEntity proof) async =>
      Success(data: PhoneVerified(proof));

  Future<Result<AuthResult>> _register(
    RegisterRequestEntity request,
    PhoneProofEntity proof,
  ) async {
    final registered = await _completeRegister(
      CompleteRegisterRequestEntity(
        phone: request.phone,
        password: request.password,
        proof: proof,
      ),
    );
    return registered.map(Registered.new);
  }
}
