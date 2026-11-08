import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/homework/data/data_sources/homework_remote_data_source.dart';
import 'package:al_mahhaba_school/features/homework/data/models/homework_page_model.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_filter.dart';

@LazySingleton(as: HomeworkRemoteDataSource)
class HomeworkRemoteDataSourceImpl implements HomeworkRemoteDataSource {
  HomeworkRemoteDataSourceImpl(@Named(ApiNames.school) this._api);

  final ApiService _api;

  static const int _perPage = 20;

  @override
  Future<HomeworkPageModel> getHomework(
    int childId, {
    HomeworkFilter filter = HomeworkFilter.all,
    int? subjectId,
    int page = 1,
    CancelHandle? cancel,
  }) async {
    final json =
        await _api.get(
              ApiEndpoints.childHomework(childId),
              queryParameters: {
                'status': switch (filter) {
                  HomeworkFilter.all => 'all',
                  HomeworkFilter.dueSoon => 'due_soon',
                  HomeworkFilter.upcoming => 'upcoming',
                  HomeworkFilter.dueToday => 'due_today',
                  HomeworkFilter.past => 'past',
                  HomeworkFilter.noDueDate => 'no_due_date',
                },
                'subject_id': ?subjectId,
                'page': page,
                'per_page': _perPage,
              },
              cancelToken: cancel?.token,
            )
            as Map<String, dynamic>;
    return HomeworkPageModel.fromJson(json);
  }
}
