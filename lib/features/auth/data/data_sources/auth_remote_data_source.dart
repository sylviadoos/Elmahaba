import 'package:al_mahhaba_school/features/auth/data/models/auth_session_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/change_password_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/complete_register_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/login_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/register_eligibility_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/register_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/reset_password_request_model.dart';

/// Talks to the school system's parent account endpoints (sign up, log in…).
/// Throws an `AppException` on failure.
abstract interface class AuthRemoteDataSource {
  /// Checks the mobile is a parent's number in the school records, before a
  /// verification code is sent to it.
  ///
  /// Fails with a `ServerException` whose `code` says why:
  /// - `invalid_phone` (422) — not an Egyptian mobile number.
  /// - `validation_failed` (422) — see `fieldErrors['password']`.
  /// - `registration_not_eligible` — not in the school records; `body` has
  ///   the school's `school_contact` (phone, email, address, working hours).
  Future<RegisterEligibilityModel> checkPhone(RegisterRequestModel request);

  /// Creates the account once Firebase verified the number, and signs in.
  ///
  /// Fails with a `ServerException` whose `code` says why:
  /// - `already_registered` — the number has an account; log in instead.
  /// - `firebase_phone_mismatch` — Firebase verified another number.
  /// - `firebase_token_invalid` — ask for a new code.
  /// - `registration_not_eligible` — as in [checkPhone].
  /// - `firebase_not_configured` — the server can't check codes right now.
  Future<AuthSessionModel> completeRegistration(
    CompleteRegisterRequestModel request,
  );

  /// Signs in with the mobile and password.
  ///
  /// Fails with a `ServerException` whose `code` says why:
  /// - `invalid_phone` (422) — not an Egyptian mobile number.
  /// - `invalid_credentials` (401) — wrong mobile or password.
  /// - `login_locked` — too many wrong tries; `body['retry_after']` is the
  ///   seconds left.
  /// - `phone_not_registered` — not in the school records; `body` has the
  ///   school's `school_contact`.
  Future<AuthSessionModel> login(LoginRequestModel request);

  /// Checks the saved token still works. An ended session fails with an
  /// `UnauthorizedException` (`unauthenticated`, 401).
  Future<void> checkSession();

  /// Sets a new password once Firebase verified the number. It doesn't
  /// sign in: the parent logs in after.
  ///
  /// Fails with a `ServerException` whose `code` says why:
  /// - `reset_verification_expired` — too long since the code; ask again.
  /// - `firebase_token_invalid` — ask for a new code.
  /// - `firebase_phone_mismatch` — Firebase verified another number.
  /// - `account_not_found` — no account with this number; sign up instead.
  /// - `validation_failed` (422) — see `fieldErrors['password']`.
  Future<void> resetPassword(ResetPasswordRequestModel request);

  /// Changes the signed-in parent's password; their other devices are
  /// signed out.
  ///
  /// Fails with a `ServerException` whose `code` says why:
  /// - `current_password_incorrect` — the current password is wrong.
  /// - `validation_failed` (422) — see `fieldErrors['password']`.
  ///
  /// An ended session fails with an `UnauthorizedException` (401).
  Future<void> changePassword(ChangePasswordRequestModel request);
}
