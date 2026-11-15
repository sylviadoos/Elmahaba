import 'package:flutter/foundation.dart';
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
      for (final result in jsonObjects(json[ApiKeys.data])) ?_read(result),
    ];
  }

  /// One result, or null when the school sent it in a shape the app can't
  /// read. On its own, so one bad result costs only itself: the child's
  /// other results still reach the parent, rather than the whole page
  /// failing over one of them.
  ///
  /// What was dropped is logged — never swallowed quietly — so it shows up
  /// while testing instead of looking like the school published nothing.
  ResultDetailsModel? _read(Map<String, dynamic> result) {
    // One without its id couldn't be told apart, or opened.
    final id = result['result_id'];
    if (id is! int) {
      debugPrint(
        'Results: a result was left out — its "result_id" is '
        '${id == null ? 'missing' : '${id.runtimeType}, not an int'}.',
      );
      return null;
    }
    try {
      return ResultDetailsModel.fromJson(result);
    } catch (error, stackTrace) {
      // The id only: the marks themselves don't belong in a log.
      debugPrint('Results: result $id could not be read: $error\n$stackTrace');
      return null;
    }
  }
}
