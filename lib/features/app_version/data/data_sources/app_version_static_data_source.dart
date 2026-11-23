import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/config/di/data_env.dart';
import 'package:al_mahhaba_school/features/app_version/data/data_sources/app_version_remote_data_source.dart';
import 'package:al_mahhaba_school/features/app_version/data/models/app_version_model.dart';

/// Stands in for the app version API while `AppConfig.useStaticData` is
/// on: the build must work without the school's server, so it's never
/// held back for an update.
@LazySingleton(as: AppVersionRemoteDataSource, env: [DataEnv.staticData])
class AppVersionStaticDataSource implements AppVersionRemoteDataSource {
  @override
  Future<AppVersionModel> check({
    required String platform,
    required String currentVersion,
  }) async => const AppVersionModel(updateAvailable: false, forceUpdate: false);
}
