import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/app_version/domain/entities/app_version_entity.dart';

/// Never throws — errors come back as a `Failure`.
abstract interface class AppVersionRepo {
  /// Asks the school about the version installed here (no sign-in needed).
  /// A forced update is kept on the phone, and forgotten once the school
  /// says there's none. Up to date where there's no store to update from
  /// (the web, a desktop).
  Future<Result<AppVersionEntity>> check();

  /// The forced update kept for the version installed now, so it still
  /// shows when the school can't be reached; null when there's none, or
  /// the app was updated since.
  Future<AppVersionEntity?> savedForcedUpdate();
}
