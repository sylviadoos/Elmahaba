import 'package:dio/dio.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/status_code.dart';

abstract final class DioExceptionHandler {
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
        final message = _messageFrom(e.response?.data);

        if (statusCode == StatusCode.expiredToken) {
          return UnauthorizedException(message: message);
        }
        return ServerException(
          message: message,
          statusCode: statusCode,
          fieldErrors: _fieldErrorsFrom(e.response?.data),
        );

      case DioExceptionType.transformTimeout:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const UnknownException();
    }
  }

  /// Reads the error text from `{"message": "..."}` or `{"error": "..."}`.
  static String? _messageFrom(Object? data) {
    if (data is Map) {
      final message = data[ApiKeys.message] ?? data[ApiKeys.error];
      if (message is String && message.isNotEmpty) return message;
    }
    return null;
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
