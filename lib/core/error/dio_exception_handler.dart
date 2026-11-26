import 'package:dio/dio.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/status_code.dart';

abstract final class DioExceptionHandler {
  /// `{"code": "unauthenticated", "message": "Please log in again."}`
  static const _sessionEndedCode = 'unauthenticated';

  /// `{"code": "session_replaced", "message": "تم تسجيل الدخول إلى حسابك من
  /// جهاز آخر…"}` (401): a parent is signed in on one phone only, so
  /// logging in on another ends this one's session. Its message, in the
  /// account's language, is shown as the parent is signed out.
  static const _sessionReplacedCode = 'session_replaced';

  /// `{"code": "account_withdrawn", "message": "…", "school_contact": {…}}`
  /// — the child left the school, so the account is closed. It can answer
  /// any request, not only log in, so the parent is signed out wherever
  /// they are in the app.
  static const _accountWithdrawnCode = 'account_withdrawn';

  /// Converts a [DioException] into a typed [AppException], so the UI can
  /// react to the kind of error (e.g. 401 → go to login).
  static AppException handle(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.cancel:
        return const CancelledException();

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        final code = _codeFrom(data);
        final message = _messageFrom(data, statusCode: statusCode, code: code);

        // Whatever the status: the account is gone, not just the session.
        if (code == _accountWithdrawnCode) {
          return UnauthorizedException(
            message: message,
            statusCode: statusCode,
            isAccountWithdrawn: true,
          );
        }
        if (statusCode == StatusCode.expiredToken &&
            code == _sessionReplacedCode) {
          return UnauthorizedException(
            message: message,
            isSessionReplaced: true,
          );
        }
        // A 401 is an ended session unless the API names another reason,
        // e.g. `invalid_credentials` for a wrong password on log in.
        if (statusCode == StatusCode.expiredToken &&
            (code == null || code == _sessionEndedCode)) {
          return UnauthorizedException(message: message);
        }
        return ServerException(
          message: message,
          statusCode: statusCode,
          code: code,
          fieldErrors: _fieldErrorsFrom(data),
          body: data is Map<String, dynamic> ? data : const {},
        );

      case DioExceptionType.transformTimeout:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const UnknownException();
    }
  }

  /// Reads the error text from `{"message": "..."}` or `{"error": "..."}` —
  /// unless it isn't meant for parents, when the app's own text is shown
  /// instead (`localizedMessage`):
  /// - a crash: the server's debug details (`exception`, `trace`: class
  ///   names and file paths), or an error status 500+ it didn't name with
  ///   a `code`;
  /// - a translation key the server left untranslated, e.g.
  ///   "parent_app.mobile_app_disabled".
  static String? _messageFrom(
    Object? data, {
    required int? statusCode,
    required String? code,
  }) {
    if (data is! Map) return null;
    final message = data[ApiKeys.message] ?? data[ApiKeys.error];
    if (message is! String || message.trim().isEmpty) return null;
    final crashed =
        data.containsKey('exception') ||
        data.containsKey('trace') ||
        (code == null &&
            statusCode != null &&
            statusCode >= StatusCode.internalServerError);
    if (crashed || _untranslatedKey.hasMatch(message.trim())) return null;
    return message;
  }

  /// "parent_app.mobile_app_disabled": words joined by dots, no spaces.
  static final _untranslatedKey = RegExp(
    r'^[A-Za-z0-9_-]+(\.[A-Za-z0-9_-]+)+$',
  );

  /// Reads `{"code": "invalid_phone"}`.
  static String? _codeFrom(Object? data) {
    final code = data is Map ? data[ApiKeys.code] : null;
    return code is String && code.isNotEmpty ? code : null;
  }

  /// Reads `{"errors": {"email": ["…", "…"]}}` (validation errors), keeping
  /// the first message of each field.
  static Map<String, String> _fieldErrorsFrom(Object? data) {
    final errors = data is Map ? data[ApiKeys.errors] : null;
    if (errors is! Map) return const {};
    return {
      for (final MapEntry(:key, :value) in errors.entries)
        if (value is List && value.isNotEmpty && value.first is String)
          key.toString(): value.first as String,
    };
  }
}
