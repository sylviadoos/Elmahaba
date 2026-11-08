import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/auth_session_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/change_password_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/complete_register_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/login_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/parent_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/session_status.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/register_eligibility_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/register_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/reset_password_request_entity.dart';

/// Never throws — errors come back as a `Failure`.
abstract interface class AuthRepo {
  /// Checks the mobile is a parent's number in the school records. A
  /// `Failure` holds a `ServerException` whose `code` says why it failed.
  Future<Result<RegisterEligibilityEntity>> checkPhone(
    RegisterRequestEntity request,
  );

  /// Signs in and keeps the session's token, so later requests send it.
  Future<Result<AuthSessionEntity>> login(LoginRequestEntity request);

  /// Sends the SMS code to [phone] — again, when given the last
  /// [resendToken].
  Future<Result<PhoneVerificationEntity>> sendOtp(
    String phone, {
    int? resendToken,
  });

  /// Checks the typed code; returns the Firebase ID token that proves the
  /// number.
  Future<Result<String>> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  /// Creates the account for the verified number. It doesn't sign in: the
  /// parent logs in after.
  Future<Result<AuthSessionEntity>> completeRegistration(
    CompleteRegisterRequestEntity request,
  );

  /// Sets a new password for the verified number. It doesn't sign in: the
  /// parent logs in after.
  Future<Result<void>> resetPassword(ResetPasswordRequestEntity request);

  /// Changes the signed-in parent's password; this device stays signed in.
  Future<Result<void>> changePassword(ChangePasswordRequestEntity request);

  /// Checks the session kept by an earlier [login] with the server. An
  /// ended one is forgotten. Fails when the server can't tell (offline…).
  Future<Result<SessionStatus>> checkSession();

  /// Forgets the session kept by [login].
  Future<Result<void>> logout();

  /// The parent kept by the last [login]; null when none is. No API call.
  Future<ParentEntity?> getSavedParent();
}
