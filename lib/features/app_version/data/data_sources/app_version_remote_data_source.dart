import 'package:al_mahhaba_school/features/app_version/data/models/app_version_model.dart';

/// Throws an `AppException` when the school can't say.
abstract interface class AppVersionRemoteDataSource {
  /// What the school says about [currentVersion] on [platform] ("android"
  /// or "ios"). No sign-in needed: asked before logging in.
  Future<AppVersionModel> check({
    required String platform,
    required String currentVersion,
  });
}
