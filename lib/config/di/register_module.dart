import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/core/network/auth_interceptor.dart';
import 'package:al_mahhaba_school/core/network/language_interceptor.dart';

/// Third-party classes that can't be annotated with @injectable directly.
@module
abstract class CoreInjectableModule {
  @preResolve
  @singleton
  Future<SharedPreferences> prefs() => SharedPreferences.getInstance();

  @lazySingleton
  FlutterSecureStorage secureStorage() => const FlutterSecureStorage();

  @lazySingleton
  InternetConnection internetConnection() => InternetConnection();

  @lazySingleton
  Dio dio(
    AuthInterceptor authInterceptor,
    LanguageInterceptor languageInterceptor,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: const {'Accept': 'application/json'},
      ),
    );

    dio.interceptors
      ..add(authInterceptor)
      ..add(languageInterceptor);
    if (AppConfig.enableLogging) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (log) => debugPrint(log.toString()),
        ),
      );
    }
    return dio;
  }
}
