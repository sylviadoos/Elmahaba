import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/auth_field_errors.dart';

void main() {
  test("the server's errors, by field", () {
    const exception = ServerException(
      statusCode: 422,
      fieldErrors: {'password': 'Too short.'},
    );

    expect(exception.authFieldErrors, {'password': 'Too short.'});
  });

  test('invalid_phone (no `errors`): its message goes on the mobile', () {
    const exception = ServerException(
      statusCode: 422,
      code: AuthErrorCodes.invalidPhone,
      message: 'Enter an Egyptian mobile number.',
    );

    expect(exception.authFieldErrors, {
      'phone_number': 'Enter an Egyptian mobile number.',
    });
  });

  test('anything else: none', () {
    expect(const NetworkException().authFieldErrors, isEmpty);
    expect(const ServerException(statusCode: 500).authFieldErrors, isEmpty);
    expect((null as AppException?).authFieldErrors, isEmpty);
  });
}
