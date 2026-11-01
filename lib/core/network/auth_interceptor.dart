import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/storage/secure_storage.dart';

/// Adds the saved access token to every request.
@singleton
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  final SecureStorage _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers[ApiKeys.token] = token;
    }
    handler.next(options);
  }
}
