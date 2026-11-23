import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/app_version/data/data_sources/app_info_data_source.dart';
import 'package:al_mahhaba_school/features/app_version/data/data_sources/app_version_local_data_source.dart';
import 'package:al_mahhaba_school/features/app_version/data/data_sources/app_version_remote_data_source.dart';
import 'package:al_mahhaba_school/features/app_version/domain/entities/app_version_entity.dart';
import 'package:al_mahhaba_school/features/app_version/domain/repos/app_version_repo.dart';

@LazySingleton(as: AppVersionRepo)
class AppVersionRepoImpl implements AppVersionRepo {
  AppVersionRepoImpl(this._remote, this._local, this._appInfo);

  final AppVersionRemoteDataSource _remote;
  final AppVersionLocalDataSource _local;
  final AppInfoDataSource _appInfo;

  @override
  Future<Result<AppVersionEntity>> check() => Result.guard(() async {
    final platform = _appInfo.platform;
    if (platform == null) return AppVersionEntity.upToDate;
    final installed = await _appInfo.version();
    var update = await _remote.check(
      platform: platform,
      currentVersion: installed,
    );
    // No store page from the school: this app's, for this phone.
    if (update.storeUrl.isEmpty) {
      update = update.withStoreUrl(AppConfig.storeUrlFor(platform));
    }
    // Kept until the school says otherwise or the app is updated: it
    // holds the app back even when the school can't be reached.
    update.forceUpdate
        ? await _local.saveForcedUpdate(installed, update)
        : await _local.clearForcedUpdate();
    return update;
  });

  @override
  Future<AppVersionEntity?> savedForcedUpdate() async {
    if (_appInfo.platform == null) return null;
    try {
      return _local.forcedUpdate(await _appInfo.version());
    } on Object {
      return null;
    }
  }
}
