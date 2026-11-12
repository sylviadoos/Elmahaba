import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/repos/results_repo.dart';

/// Every result published for a child, newest first:
/// `final results = await getResults(child.studentId);`
@lazySingleton
class GetResultsUseCase {
  GetResultsUseCase(this._repo);

  final ResultsRepo _repo;

  Future<Result<List<ResultDetailsEntity>>> call(int childId) =>
      _repo.getResults(childId);
}
