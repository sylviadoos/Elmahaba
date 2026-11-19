import 'package:flutter/foundation.dart';

/// Build environment, chosen at build time:
/// `flutter run --dart-define=ENV=prod` (defaults to `dev`).
enum Environment { dev, staging, prod }

abstract final class AppConfig {
  static const String appName = 'Al Mahabbah Schools';

  static final Environment environment = Environment.values.byName(
    const String.fromEnvironment('ENV', defaultValue: 'dev'),
  );

  // Keep the trailing `/` — endpoints in ApiEndpoints have no leading `/`.
  // dev (what you run): leave ONE line uncommented in each, the server
  // you want. staging and prod (Jenkins' ENV) are the live servers.

  /// The live website's API.
  static const String _liveWebsite =
      'https://almahabbahschools.com/public/api/';

  /// The live school system's (portal's) API.
  static const String _liveSchool =
      'https://admin.almahabbahschools.com/school-mahaba-app/public/api/';

  /// The school website: news, contact us… (visitor screens).
  static String get websiteBaseUrl => switch (environment) {
    Environment.dev =>
      // Office:
      // 'http://192.168.0.219/Almahabbah-schools-Website/public/api/',
      // Live:
      _liveWebsite,
    Environment.staging || Environment.prod => _liveWebsite,
  };

  /// The school system: parent account, children, results… (parent screens).
  static String get schoolBaseUrl => switch (environment) {
    Environment.dev =>
      // Office:
      // 'http://192.168.0.219/Almahhaba-School-back-API/public/api/',
      // Live:
      _liveSchool,
    //'http://192.168.0.106:8080/mariam_hany/almahaba316/Almahhaba-School-back-API/public/api/',
    Environment.staging || Environment.prod => _liveSchool,
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

  /// Microsoft Clarity (session recordings and heatmaps): the project, from
  /// the Settings page of the Clarity dashboard.
  static const String clarityProjectId = 'zaxu0cd0u4';

  /// Recording with Clarity: release and profile builds only, so developers'
  /// sessions don't mix with parents'. To try it in a debug build:
  /// `flutter run --dart-define=CLARITY=true` ("Debug + Clarity" in VS
  /// Code).
  static const bool clarityEnabled = bool.fromEnvironment(
    'CLARITY',
    defaultValue: !kDebugMode,
  );

  /// Sentry (errors, beside Crashlytics): the project's DSN, from Sentry ›
  /// Settings › Projects › el-mahabba-school › Client Keys. Not a secret:
  /// every build carries it. A build can send elsewhere with
  /// `--dart-define=SENTRY_DSN=…`; empty, Sentry stays off.
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue:
        'https://569e5a0bb96a9821fa3b6d1e4247ff23@o4512401874288640.ingest.us.sentry.io/4512402023186432',
  );

  /// Sending errors to Sentry: release and profile builds only, like
  /// Clarity. To try it in a debug build: `flutter run
  /// --dart-define=SENTRY=true` ("Debug + Sentry" in VS Code).
  static const bool sentryEnabled =
      sentryDsn != '' &&
      bool.fromEnvironment('SENTRY', defaultValue: !kDebugMode);

  /// Who sends the SMS codes first (sign-up, forgot password, linking a
  /// child): the school (SMS Misr) when true, Firebase when false — the
  /// other only when the first fails. Flip the value below to switch, or
  /// run with `--dart-define=SMS_MISR_FIRST=true` for one run ("Debug +
  /// school OTP").
  ///
  /// On: the school first. Its catch: the school answers `otp_sent`
  /// whether SMS Misr sent the text or not, so one that never arrives
  /// reads as a success and nothing falls back. Firebase has the opposite
  /// catch — it sends no SMS without
  /// its billing (Blaze), yet says it did — so if no code arrives from it
  /// either, that billing is where to look.
  static const bool smsMisrFirst = bool.fromEnvironment(
    'SMS_MISR_FIRST',
    // true  → the school first, Firebase if it fails.
    // false → Firebase first, the school if it fails.
    defaultValue: true,
  );

  /// [smsMisrFirst]'s name in dependency injection.
  static const String smsMisrFirstName = 'smsMisrFirst';

  static bool get isProduction => environment == Environment.prod;

  /// Network and router logs: debug builds only, never production. Release
  /// builds stay quiet — API responses hold parents' and children's data.
  static bool get enableLogging => kDebugMode && !isProduction;

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
