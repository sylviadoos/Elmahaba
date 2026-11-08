import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:al_mahhaba_school/core/network/api_keys.dart';

/// Prints every API call once it ends — the request with its response or
/// error — with passwords and tokens hidden:
///
/// ```
/// ┌─ [schoolApi] POST http://…/api/mobile/login
/// │ Headers: {Accept-Language: en}
/// │ Body: {"phone_number": "01000000000", "password": "•••", …}
/// └─ 401 in 512 ms
/// {
///   "status": "error",
///   "code": "invalid_credentials",
///   …
/// }
/// ```
class ApiLogInterceptor extends Interceptor {
  ApiLogInterceptor(this.apiName);

  /// Which server, e.g. `websiteApi` (see `ApiNames`).
  final String apiName;

  static const _startedAt = 'apiLogStartedAt';
  static const _hidden = '•••';

  /// Fields never printed as they are.
  static const _secretKeys = {
    'password',
    'password_confirmation',
    'firebase_id_token',
    'access_token',
  };

  /// Long HTML error pages are cut to this many characters.
  static const _maxTextLength = 1500;

  /// And long JSON bodies to this many.
  static const _maxJsonLength = 4000;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAt] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log(response.requestOptions, '${response.statusCode}', response.data);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    _log(
      err.requestOptions,
      status != null ? '$status' : '✗ ${err.type.name}',
      err.response?.data ?? err.message,
    );
    handler.next(err);
  }

  void _log(RequestOptions options, String outcome, Object? responseData) {
    final startedAt = options.extra[_startedAt] as DateTime?;
    final took = startedAt == null
        ? ''
        : ' in ${DateTime.now().difference(startedAt).inMilliseconds} ms';

    final log = StringBuffer()
      ..writeln('┌─ [$apiName] ${options.method} ${options.uri}')
      ..writeln('│ Headers: ${_headers(options.headers)}');
    if (options.data != null) log.writeln('│ Body: ${_format(options.data)}');
    log
      ..writeln('└─ $outcome$took')
      ..write(_format(responseData, indent: true));

    debugPrint(log.toString());
  }

  /// Only the headers worth seeing; the token shows as present, not its value.
  static Map<String, Object?> _headers(Map<String, dynamic> headers) => {
    for (final key in [ApiKeys.acceptLanguage, ApiKeys.authorization])
      if (headers[key] != null)
        key: key == ApiKeys.authorization ? 'Bearer $_hidden' : headers[key],
  };

  static String _format(Object? data, {bool indent = false}) {
    if (data == null) return '(empty)';
    if (data is FormData) {
      return 'FormData(fields: ${data.fields.map((e) => e.key).toList()}, '
          'files: ${data.files.map((e) => e.key).toList()})';
    }
    if (data is Map || data is List) {
      try {
        final encoder = indent
            ? const JsonEncoder.withIndent('  ')
            : const JsonEncoder();
        return _cut(encoder.convert(_hideSecrets(data)), _maxJsonLength);
      } catch (_) {
        // Not encodable as JSON: fall back to toString.
      }
    }
    return _cut('$data', _maxTextLength);
  }

  /// A whole chat page, say, printed in full slows the app down (debug
  /// builds only) and floods the console.
  static String _cut(String text, int max) => text.length > max
      ? '${text.substring(0, max)}… (${text.length} chars)'
      : text;

  /// Secrets are text; under the same key, a 422's error list stays visible.
  static Object? _hideSecrets(Object? data) => switch (data) {
    Map() => {
      for (final MapEntry(:key, :value) in data.entries)
        '$key': _secretKeys.contains(key) && value is String
            ? _hidden
            : _hideSecrets(value),
    },
    List() => [for (final item in data) _hideSecrets(item)],
    _ => data,
  };
}
