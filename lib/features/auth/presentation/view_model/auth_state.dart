import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/auth_session_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/register_eligibility_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/register_request_entity.dart';

/// Success carries what the action ended with — each page reacts to its own.
typedef AuthState = BaseState<AuthResult>;

sealed class AuthResult {
  const AuthResult();
}

/// The mobile can sign up: verify it next (OTP). Passed to the OTP page.
final class PhoneEligible extends AuthResult {
  const PhoneEligible(this.request, this.eligibility);

  /// What the parent filled in — the account is created with it.
  final RegisterRequestEntity request;
  final RegisterEligibilityEntity eligibility;
}

/// The SMS code was sent.
final class OtpSent extends AuthResult {
  const OtpSent();
}

/// The account was created: the parent logs in next.
final class Registered extends AuthResult {
  const Registered(this.session);

  final AuthSessionEntity session;
}

/// Logged in: the token is kept, so the next launch opens Home.
final class LoggedIn extends AuthResult {
  const LoggedIn(this.session);

  final AuthSessionEntity session;
}

/// Forgot password: Firebase verified the number — by the typed code, or
/// by itself on Android.
final class PhoneVerified extends AuthResult {
  const PhoneVerified(this.firebaseIdToken);

  /// Sent with the new password, as proof.
  final String firebaseIdToken;
}

/// Forgot password: the new password is set; the parent logs in next.
final class PasswordReset extends AuthResult {
  const PasswordReset();
}

/// Profile: the password is changed; this device stays signed in.
final class PasswordChanged extends AuthResult {
  const PasswordChanged();
}
