import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:al_mahhaba_school/features/home/data/models/announcement_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/child_dashboard_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/latest_items_model.dart';
import 'package:al_mahhaba_school/features/home/data/models/latest_result_model.dart';
import 'package:al_mahhaba_school/features/homework/data/models/homework_model.dart';

@LazySingleton(as: HomeRemoteDataSource)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl(@Named(ApiNames.school) this._api);

  final ApiService _api;

  @override
  Future<ChildDashboardModel> getChildDashboard(int childId) async {
    // { "status": "success", "data": { "child": {...}, "attendance": {...},
    //   "results": {...}, "fees": {...}, "messages": {...} } }
    final json =
        await _api.get(ApiEndpoints.childDashboard(childId))
            as Map<String, dynamic>;
    return ChildDashboardModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }

  @override
  Future<LatestItemsModel<AnnouncementModel>> getLatestAnnouncements(
    int childId,
  ) => _latest(
    ApiEndpoints.childAnnouncementsLatest(childId),
    AnnouncementModel.fromJson,
  );

  @override
  Future<LatestItemsModel<HomeworkModel>> getLatestHomework(int childId) =>
      _latest(
        ApiEndpoints.childHomeworkLatest(childId),
        HomeworkModel.fromJson,
      );

  @override
  Future<LatestItemsModel<LatestResultModel>> getLatestResults(int childId) =>
      _latest(
        ApiEndpoints.childResultsLatest(childId),
        LatestResultModel.fromJson,
      );

  /// { "status": "success", "data": [ … ], "meta": { "limit": 3,
  ///   "total": 7, "unread": 0 } }
  Future<LatestItemsModel<T>> _latest<T>(
    String path,
    T Function(Map<String, dynamic> json) item,
  ) async {
    final json = await _api.get(path) as Map<String, dynamic>;
    return LatestItemsModel.fromJson(json, item);
  }
}
