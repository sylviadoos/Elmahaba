import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/network/status_code.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';

extension SchoolSmsDown on AppException {
  /// The school couldn't text a code for its own reasons — SMS Misr failed
  /// (`otp_send_failed`), or the server broke — so Firebase may send it
  /// instead. Not when the school refused on purpose (too soon, too many,
  /// a number it doesn't know), nor offline: Firebase can't do better.
  bool get isSchoolSmsDown => switch (this) {
    ServerException(code: AuthErrorCodes.otpSendFailed) => true,
    ServerException(code: null, :final statusCode?) =>
      statusCode >= StatusCode.internalServerError,
    UnknownException() => true,
    _ => false,
  };
}
