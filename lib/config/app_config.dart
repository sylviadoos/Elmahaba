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
  static String get baseUrl => switch (environment) {
    // Local server on the office network (plain http).
    Environment.dev =>
      'http://192.168.0.219/Almahabbah-schools-Website/public/api/',
    Environment.staging => 'https://staging.example.com/api/v1/',
    Environment.prod => 'https://api.example.com/api/v1/',
  };

  /// Parent log in and everything behind it (Home, Chat, Results…).
  ///
  /// Off for now: the app is visitor-only — the Log in button is hidden and
  /// parent screens redirect to Explore. Turn on with
  /// `flutter run --dart-define=PARENT_ACCOUNT=true`, or change the default.
  static const bool parentAccountEnabled = bool.fromEnvironment(
    'PARENT_ACCOUNT',
  );

  /// News and contact details built into the app instead of loaded from the
  /// API — on for now, while the school's server isn't online.
  ///
  /// On, the contact form is hidden too (it can only send through the API).
  /// Use the API with `flutter run --dart-define=STATIC_DATA=false`, or
  /// change the default.
  static const bool useStaticData = bool.fromEnvironment(
    'STATIC_DATA',
    defaultValue: true,
  );

  static bool get isProduction => environment == Environment.prod;

  /// Network and router logs are printed everywhere except production.
  static bool get enableLogging => !isProduction;

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
