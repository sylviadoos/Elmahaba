/// This app as installed on the phone.
abstract interface class AppInfoDataSource {
  /// The installed version, as the stores show it: "1.0.0" (the part of
  /// `version:` in pubspec.yaml before the `+`).
  Future<String> version();

  /// "android" or "ios"; null where there's no store to update from (the
  /// web, a desktop).
  String? get platform;
}
