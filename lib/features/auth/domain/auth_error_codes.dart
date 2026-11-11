/// The `code` of the auth errors the app reacts to.
abstract final class AuthErrorCodes {
  // School API (`ServerException.code`).

  /// Not an Egyptian mobile number (422, no `errors`).
  static const String invalidPhone = 'invalid_phone';

  /// Not a parent's number in the school records; the body has the school's
  /// `school_contact`.
  static const String registrationNotEligible = 'registration_not_eligible';

  /// Signing up a number that already has an account.
  static const String alreadyRegistered = 'already_registered';

  /// Resetting a password: too long since the code was checked.
  static const String resetVerificationExpired = 'reset_verification_expired';

  /// Firebase's proof of the number didn't check out: ask for a new code.
  static const String firebaseTokenInvalid = 'firebase_token_invalid';

  /// Firebase verified another number than the one typed.
  static const String firebasePhoneMismatch = 'firebase_phone_mismatch';

  /// Resetting the password of a number with no account.
  static const String accountNotFound = 'account_not_found';

  /// Logging in: too many wrong passwords, so the number is locked for a
  /// while (429); the body's `retry_after` is the seconds left.
  static const String loginLocked = 'login_locked';

  /// Changing the password: the current one typed is wrong.
  static const String currentPasswordIncorrect = 'current_password_incorrect';

  // Firebase phone auth (`PhoneVerificationException.code`).

  static const String wrongCode = 'invalid-verification-code';
  static const String codeExpired = 'session-expired';
  static const String tooManyRequests = 'too-many-requests';
  static const String quotaExceeded = 'quota-exceeded';

  /// Verifying before a code was sent.
  static const String noCodeSent = 'missing-verification-id';
}
