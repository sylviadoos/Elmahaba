import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/results/data/data_sources/results_remote_data_source.dart';
import 'package:al_mahhaba_school/features/results/data/models/result_details_model.dart';

@LazySingleton(as: ResultsRemoteDataSource)
class ResultsRemoteDataSourceImpl implements ResultsRemoteDataSource {
  ResultsRemoteDataSourceImpl(@Named(ApiNames.school) this._api);

  final ApiService _api;

  @override
  Future<ResultDetailsModel> getResult({
    required int childId,
    required int resultId,
  }) async {
    // { "status": "success", "data": { "id": 53, "title": "…",
    //   "result_type": "value and color", "result": { … } } }
    final json =
        await _api.get(ApiEndpoints.childResult(childId, resultId))
            as Map<String, dynamic>;
    return ResultDetailsModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }
}
