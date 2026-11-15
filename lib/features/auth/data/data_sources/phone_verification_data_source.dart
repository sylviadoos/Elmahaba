import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';

/// Proves the parent owns their mobile with an SMS code (Firebase phone
/// auth). Throws an `AppException` on failure — a
/// `PhoneVerificationException` with Firebase's `code` for most of them.
abstract interface class PhoneVerificationDataSource {
  /// Sends a code to [phone] (local, e.g. "01201234154"). To send it again,
  /// pass the `resendToken` of the last [SmsCodeSent].
  ///
  /// Some Android phones verify the number without a code:
  /// [PhoneAutoVerified].
  Future<PhoneVerificationEntity> sendCode(String phone, {int? resendToken});

  /// Checks the code the parent typed and returns the Firebase ID token the
  /// school API asks for. A wrong code fails with
  /// `invalid-verification-code`, an old one with `session-expired`.
  Future<String> verifyCode({
    required String verificationId,
    required String smsCode,
  });

  /// Ends the Firebase sign-in: once the account exists, the school API's
  /// token is used instead.
  Future<void> signOut();
}
