import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/app_status/data/data_sources/app_status_remote_data_source.dart';
import 'package:al_mahhaba_school/features/app_status/domain/entities/app_status_entity.dart';
import 'package:al_mahhaba_school/features/app_status/domain/repos/app_status_repo.dart';

@LazySingleton(as: AppStatusRepo)
class AppStatusRepoImpl implements AppStatusRepo {
  AppStatusRepoImpl(this._remoteDataSource);

  final AppStatusRemoteDataSource _remoteDataSource;

  @override
  Future<Result<AppStatusEntity>> getAppStatus() =>
      Result.guard(_remoteDataSource.getAppStatus);
}
