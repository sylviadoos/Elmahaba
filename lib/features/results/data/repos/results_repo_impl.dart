import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/results/data/data_sources/results_remote_data_source.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/repos/results_repo.dart';

@LazySingleton(as: ResultsRepo)
class ResultsRepoImpl implements ResultsRepo {
  ResultsRepoImpl(this._remoteDataSource);

  final ResultsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<ResultDetailsEntity>> getResult({
    required int childId,
    required int resultId,
  }) => Result.guard(
    () => _remoteDataSource.getResult(childId: childId, resultId: resultId),
  );
}
