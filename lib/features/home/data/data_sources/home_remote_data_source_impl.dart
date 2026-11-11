import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:al_mahhaba_school/features/home/data/models/child_dashboard_model.dart';

@LazySingleton(as: HomeRemoteDataSource)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl(@Named(ApiNames.school) this._api);

  final ApiService _api;

  @override
  Future<ChildDashboardModel> getChildDashboard(int childId) async {
    // { "status": "success", "data": { "child": {...}, "attendance": {...},
    //   "announcements": {...}, "homework": {...}, "results": {...},
    //   "fees": {...}, "messages": {...} } }
    final json =
        await _api.get(ApiEndpoints.childDashboard(childId))
            as Map<String, dynamic>;
    return ChildDashboardModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }
}
