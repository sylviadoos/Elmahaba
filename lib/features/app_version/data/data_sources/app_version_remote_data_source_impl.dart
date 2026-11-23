import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/config/di/data_env.dart';
import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/app_version/data/data_sources/app_version_remote_data_source.dart';
import 'package:al_mahhaba_school/features/app_version/data/models/app_version_model.dart';

@LazySingleton(as: AppVersionRemoteDataSource, env: [DataEnv.api])
class AppVersionRemoteDataSourceImpl implements AppVersionRemoteDataSource {
  AppVersionRemoteDataSourceImpl(@Named(ApiNames.school) this._api);

  final ApiService _api;

  @override
  Future<AppVersionModel> check({
    required String platform,
    required String currentVersion,
  }) async {
    // { "status": "success", "data": { "update_available": true,
    //   "force_update": false, … } }
    final json =
        await _api.get(
              ApiEndpoints.appVersion,
              queryParameters: {
                'platform': platform,
                'current_version': currentVersion,
              },
            )
            as Map<String, dynamic>;
    return AppVersionModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>? ?? const {},
    );
  }
}
