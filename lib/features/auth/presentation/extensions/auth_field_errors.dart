import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';

extension AuthFieldErrors on AppException? {
  /// Server errors to show under the auth forms' fields, keyed by API field
  /// name. `invalid_phone` comes without `errors`, so it goes on the phone.
  Map<String, String> get authFieldErrors => switch (this) {
    ServerException(code: AuthErrorCodes.invalidPhone, :final message?) => {
      'phone_number': message,
    },
    ServerException(:final fieldErrors) => fieldErrors,
    _ => const {},
  };
}
