import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';

extension LoginLocked on AppException? {
  /// How long logging in with that number stays locked after too many
  /// wrong passwords (`login_locked`'s `retry_after`); null for any other
  /// error, or when the school didn't say.
  Duration? get loginLockedFor => switch (this) {
    ServerException(
      code: AuthErrorCodes.loginLocked,
      body: {'retry_after': final num seconds},
    )
        when seconds > 0 =>
      Duration(seconds: seconds.ceil()),
    _ => null,
  };
}
