import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';

/// The school's own SMS code (SMS Misr), for when Firebase can't send one.
/// Throws an `AppException` on failure — a `ServerException` with the
/// school's `code` (`phone_not_registered`, `otp_resend_too_soon`,
/// `otp_resend_limit`, `otp_send_failed`…) and its message.
abstract interface class SchoolOtpDataSource {
  /// Texts a 6-digit code to [phone] (local, e.g. "01201234154"). The
  /// code isn't checked here: it goes with the request that needs the
  /// number proved.
  Future<SchoolCodeSent> sendCode(String phone);
}
