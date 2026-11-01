import 'package:al_mahhaba_school/config/app_config.dart';

/// Injectable environments that pick where feature data comes from.
///
/// Give each data source implementation one of these, e.g.
/// `@LazySingleton(as: NewsRemoteDataSource, env: [DataEnv.api])`.
/// Classes without an `env` are registered in both.
abstract final class DataEnv {
  /// The school API.
  static const String api = 'api';

  /// Content built into the app (see `AppConfig.useStaticData`).
  static const String staticData = 'static';

  static String get current => AppConfig.useStaticData ? staticData : api;
}
