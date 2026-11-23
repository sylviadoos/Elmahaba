import 'package:al_mahhaba_school/features/app_version/data/models/app_version_model.dart';

/// The forced update kept on the phone, so the app stays held back even
/// when the school can't be reached, until it's updated.
abstract interface class AppVersionLocalDataSource {
  /// The forced update kept for [installedVersion]; null when there's none,
  /// or it was kept for another version (the app was updated since).
  AppVersionModel? forcedUpdate(String installedVersion);

  /// Keeps [update] as forced for [installedVersion].
  Future<void> saveForcedUpdate(
    String installedVersion,
    AppVersionModel update,
  );

  Future<void> clearForcedUpdate();
}
