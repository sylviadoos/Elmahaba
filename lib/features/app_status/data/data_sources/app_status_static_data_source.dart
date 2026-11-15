import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/config/di/data_env.dart';
import 'package:al_mahhaba_school/features/app_status/data/data_sources/app_status_remote_data_source.dart';
import 'package:al_mahhaba_school/features/app_status/data/models/app_status_model.dart';

/// Stands in for the app status API while `AppConfig.useStaticData` is on:
/// enabled, so "Log in" is up to `AppConfig.parentAccountEnabled` alone, as
/// before.
@LazySingleton(as: AppStatusRemoteDataSource, env: [DataEnv.staticData])
class AppStatusStaticDataSource implements AppStatusRemoteDataSource {
  @override
  Future<AppStatusModel> getAppStatus() async =>
      const AppStatusModel(enabled: true);
}
