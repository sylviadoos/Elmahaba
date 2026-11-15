import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/config/di/data_env.dart';
import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/app_status/data/data_sources/app_status_remote_data_source.dart';
import 'package:al_mahhaba_school/features/app_status/data/models/app_status_model.dart';

@LazySingleton(as: AppStatusRemoteDataSource, env: [DataEnv.api])
class AppStatusRemoteDataSourceImpl implements AppStatusRemoteDataSource {
  AppStatusRemoteDataSourceImpl(@Named(ApiNames.school) this._api);

  final ApiService _api;

  @override
  Future<AppStatusModel> getAppStatus() async {
    // { "status": "success", "data": { "enabled": true, "message": null } }
    final json = await _api.get(ApiEndpoints.appStatus) as Map<String, dynamic>;
    return AppStatusModel.fromJson(json[ApiKeys.data] as Map<String, dynamic>);
  }
}
