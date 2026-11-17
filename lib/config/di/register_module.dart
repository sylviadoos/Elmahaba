import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/core/network/api_log_interceptor.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
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

  /// Sends and checks the SMS codes that verify a parent's mobile.
  @lazySingleton
  FirebaseAuth firebaseAuth() => FirebaseAuth.instance;

  /// Whether the school (SMS Misr) sends the SMS codes first, not Firebase.
  @Named(AppConfig.smsMisrFirstName)
  bool smsMisrFirst() => AppConfig.smsMisrFirst;

  /// Push notifications: this phone's token, and the pushes themselves.
  @lazySingleton
  FirebaseMessaging firebaseMessaging() => FirebaseMessaging.instance;

  /// Shows the pushes that arrive while the app is open (Android).
  @lazySingleton
  FlutterLocalNotificationsPlugin localNotifications() =>
      FlutterLocalNotificationsPlugin();

  @lazySingleton
  DeviceInfoPlugin deviceInfo() => DeviceInfoPlugin();

  /// The school website — public data, so no auth token.
  @Named(ApiNames.website)
  @lazySingleton
  ApiService websiteApi(LanguageInterceptor languageInterceptor) => ApiService(
    _dio(ApiNames.website, AppConfig.websiteBaseUrl, [languageInterceptor]),
  );

  /// The school system — sends the parent's token.
  @Named(ApiNames.school)
  @lazySingleton
  ApiService schoolApi(
    AuthInterceptor authInterceptor,
    LanguageInterceptor languageInterceptor,
  ) => ApiService(
    _dio(ApiNames.school, AppConfig.schoolBaseUrl, [
      authInterceptor,
      languageInterceptor,
    ]),
  );

  /// Signed file links, which are full URLs — no token, no headers added.
  @Named(ApiNames.signedFiles)
  @lazySingleton
  ApiService signedFilesApi() =>
      ApiService(_dio(ApiNames.signedFiles, '', const []));
}

/// [name] labels the server in the logs.
Dio _dio(String name, String baseUrl, List<Interceptor> interceptors) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.addAll(interceptors);
  // Last, so it logs the headers the others added.
  if (AppConfig.enableLogging) dio.interceptors.add(ApiLogInterceptor(name));
  return dio;
}
