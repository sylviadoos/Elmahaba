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

  group('logged in on another phone (session_replaced)', () {
    const message =
        'تم تسجيل الدخول إلى حسابك من جهاز آخر. يرجى تسجيل الدخول مرة أخرى.';

    /// As the API sends it, to any request from the phone it replaced.
    final body = {
      'status': 'error',
      'code': 'session_replaced',
      'message': message,
    };

    test('signs the parent out, with the server\'s message', () {
      final exception = DioExceptionHandler.handle(_answer(401, body));

      expect(
        exception,
        isA<UnauthorizedException>()
            .having((e) => e.isSessionReplaced, 'isSessionReplaced', isTrue)
            .having((e) => e.isAccountWithdrawn, 'isAccountWithdrawn', isFalse)
            .having((e) => e.message, 'message', message),
      );
    });

    test('an ended session is not one', () {
      final exception = DioExceptionHandler.handle(
        _answer(401, {'code': 'unauthenticated', 'message': 'Log in again.'}),
      );

      expect(
        exception,
        isA<UnauthorizedException>().having(
          (e) => e.isSessionReplaced,
          'isSessionReplaced',
          isFalse,
        ),
      );
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

  group('messages not meant for parents are dropped', () {
    test('a crash, with its debug details', () {
      final exception = DioExceptionHandler.handle(
        _answer(500, {
          'message':
              r'Brick\Math\BigNumber::isGreaterThanOrEqualTo(): Argument #1 '
              'must be of type BigNumber, null given',
          'exception': 'TypeError',
          'file': '/home/customer/www/vendor/brick/math/src/BigNumber.php',
          'trace': <Object>[],
        }),
      );

      expect(exception, isA<ServerException>());
      expect(exception.message, isNull);
    });

    test('a 500 the API did not name', () {
      final exception = DioExceptionHandler.handle(
        _answer(500, {'message': 'Server Error'}),
      );

      expect(exception.message, isNull);
    });

    test('an untranslated key', () {
      final exception = DioExceptionHandler.handle(
        _answer(503, {
          'status': 'error',
          'code': 'mobile_app_disabled',
          'message': 'parent_app.mobile_app_disabled',
        }),
      );

      expect(
        exception,
        isA<ServerException>()
            .having((e) => e.code, 'code', 'mobile_app_disabled')
            .having((e) => e.message, 'message', isNull),
      );
    });

    test('a named error, even a 503: its message is kept', () {
      final exception = DioExceptionHandler.handle(
        _answer(503, {
          'code': 'otp_send_failed',
          'message': 'We could not send the code. Please try again.',
        }),
      );

      expect(
        exception.message,
        'We could not send the code. Please try again.',
      );
    });
  });
}
