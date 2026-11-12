import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/results/data/data_sources/results_remote_data_source.dart';
import 'package:al_mahhaba_school/features/results/data/models/result_details_model.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_kind.dart';

@LazySingleton(as: ResultsRemoteDataSource)
class ResultsRemoteDataSourceImpl implements ResultsRemoteDataSource {
  ResultsRemoteDataSourceImpl(@Named(ApiNames.school) this._api);

  final ApiService _api;

  @override
  Future<List<ResultDetailsModel>> getResults(
    int childId, {
    required ResultKind kind,
  }) async {
    // { "status": "success", "data": [ …result… ],
    //   "meta": { "total": 2, "periods": [ … ], "academic_years": [ … ] } }
    final json =
        await _api.get(
              ApiEndpoints.childResults(childId),
              queryParameters: {'result_type': kind.name},
            )
            as Map<String, dynamic>;
    return [
      for (final result in jsonObjects(json[ApiKeys.data]))
        // One without its id couldn't be told apart.
        if (result['result_id'] is int) ResultDetailsModel.fromJson(result),
    ];
  }
}
