import 'package:flutter/foundation.dart';

/// Build environment, chosen at build time:
/// `flutter run --dart-define=ENV=prod` (defaults to `dev`).
enum Environment { dev, staging, prod }

abstract final class AppConfig {
  static const String appName = 'Al Mahabbah Schools';

  static final Environment environment = Environment.values.byName(
    const String.fromEnvironment('ENV', defaultValue: 'dev'),
  );

  // TODO: replace the staging and prod URLs with the real ones.
  // Keep the trailing `/` — endpoints in ApiEndpoints have no leading `/`.
  // dev = local servers on the office network (plain http).

  /// The school website: news, contact us… (visitor screens).
  static String get websiteBaseUrl => switch (environment) {
    Environment.dev =>
      'http://192.168.0.219/Almahabbah-schools-Website/public/api/',
    Environment.staging => 'https://staging.example.com/api/',
    Environment.prod => 'https://example.com/api/',
  };

  /// The school system: parent account, children, results… (parent screens).
  static String get schoolBaseUrl => switch (environment) {
    Environment.dev =>
     // 'http://192.168.0.219/Almahhaba-School-back-API/public/api/',
      'http://192.168.0.106:8080/mariam_hany/almahaba314/Almahhaba-School-back-API/public/api/',

    Environment.staging => 'https://staging-api.example.com/api/',
    Environment.prod => 'https://api.example.com/api/',
  };

  /// Parent log in and everything behind it (Home, Chat, Results…).
  ///
  /// On by default. Off, the app is visitor-only — the Log in button is
  /// hidden and parent screens redirect to Explore. Turn off with
  /// `flutter run --dart-define=PARENT_ACCOUNT=false`.
  static const bool parentAccountEnabled = bool.fromEnvironment(
    'PARENT_ACCOUNT',
    defaultValue: true,
  );

  /// News and contact details built into the app instead of loaded from the
  /// API — for builds that must work without the school's server.
  ///
  /// On, the contact form is hidden too (it can only send through the API).
  /// Off by default; turn on with `flutter run --dart-define=STATIC_DATA=true`.
  static const bool useStaticData = bool.fromEnvironment('STATIC_DATA');

  static bool get isProduction => environment == Environment.prod;

  /// Network and router logs: debug builds only, never production. Release
  /// builds stay quiet — API responses hold parents' and children's data.
  static bool get enableLogging => kDebugMode && !isProduction;

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
