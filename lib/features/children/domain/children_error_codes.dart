/// The `code` of the school API's children errors (`ServerException.code`).
abstract final class ChildrenErrorCodes {
  /// The child is on the parent's account already.
  static const String alreadyLinked = 'child_already_linked';

  /// Linking by a texted code: the code is wrong; `attempts_left` says how
  /// many tries remain.
  static const String codeIncorrect = 'otp_incorrect';

  /// The code is too old: a new one can be asked for.
  static const String codeExpired = 'otp_expired';

  /// The check itself is gone (too old, or unknown): start again from the
  /// national ID.
  static const String verificationInvalid = 'link_verification_invalid';

  /// Too many wrong codes: no more tries for now.
  static const String attemptsExceeded = 'link_attempts_exceeded';

  /// Another code asked for too soon; `retry_after` says in how long.
  static const String resendTooSoon = 'otp_resend_too_soon';

  /// No more codes can be asked for.
  static const String resendLimit = 'otp_resend_limit';
}
