import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/announcements/data/data_sources/announcements_remote_data_source.dart';
import 'package:al_mahhaba_school/features/announcements/data/models/announcements_page_model.dart';

@LazySingleton(as: AnnouncementsRemoteDataSource)
class AnnouncementsRemoteDataSourceImpl
    implements AnnouncementsRemoteDataSource {
  AnnouncementsRemoteDataSourceImpl(@Named(ApiNames.school) this._api);

  final ApiService _api;

  static const int _perPage = 10;

  @override
  Future<AnnouncementsPageModel> getAnnouncements(
    int childId, {
    int page = 1,
    CancelHandle? cancel,
  }) async {
    final json =
        await _api.get(
              ApiEndpoints.childAnnouncements(childId),
              queryParameters: {'page': page, 'per_page': _perPage},
              cancelToken: cancel?.token,
            )
            as Map<String, dynamic>;
    return AnnouncementsPageModel.fromJson(json);
  }
}
