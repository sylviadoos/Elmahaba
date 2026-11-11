import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/error/dio_exception_handler.dart';

final _request = RequestOptions(path: 'mobile/login');

/// What the API answered: a status and its body.
DioException _answer(int statusCode, Map<String, dynamic> body) => DioException(
  requestOptions: _request,
  type: DioExceptionType.badResponse,
  response: Response<Map<String, dynamic>>(
    requestOptions: _request,
    statusCode: statusCode,
    data: body,
  ),
);

void main() {
  group('a closed account (account_withdrawn)', () {
    const message =
        'Your account is no longer available because your child has been '
        'withdrawn from the school. Please contact the school.';

    /// As the API sends it: the reason, and whom to ask about it.
    final body = {
      'status': 'error',
      'code': 'account_withdrawn',
      'message': message,
      'school_contact': {'phone': '0222****000'},
    };

    test('signs the parent out, with the school\'s message', () {
      final exception = DioExceptionHandler.handle(_answer(403, body));

      expect(
        exception,
        isA<UnauthorizedException>()
            .having((e) => e.isAccountWithdrawn, 'isAccountWithdrawn', isTrue)
            .having((e) => e.message, 'message', message),
      );
    });

    test('whatever status it comes with', () {
      for (final statusCode in [401, 403, 422]) {
        expect(
          DioExceptionHandler.handle(_answer(statusCode, body)),
          isA<UnauthorizedException>().having(
            (e) => e.isAccountWithdrawn,
            'isAccountWithdrawn',
            isTrue,
          ),
          reason: 'status $statusCode',
        );
      }
    });
  });

  group('the other 401s are left as they were', () {
    test('an ended session: signed out, not withdrawn', () {
      final exception = DioExceptionHandler.handle(
        _answer(401, {'code': 'unauthenticated', 'message': 'Log in again.'}),
      );

      expect(
        exception,
        isA<UnauthorizedException>().having(
          (e) => e.isAccountWithdrawn,
          'isAccountWithdrawn',
          isFalse,
        ),
      );
    });

    test('a wrong password: a server error the log in page shows', () {
      final exception = DioExceptionHandler.handle(
        _answer(401, {'code': 'invalid_credentials', 'message': 'Wrong.'}),
      );

      expect(
        exception,
        isA<ServerException>().having(
          (e) => e.code,
          'code',
          'invalid_credentials',
        ),
      );
    });
  });
}
