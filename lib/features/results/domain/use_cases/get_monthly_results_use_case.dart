import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_results_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/repos/results_repo.dart';

/// A child's monthly results and certificate:
/// `final result = await getMonthlyResults(child.studentId);`
@lazySingleton
class GetMonthlyResultsUseCase {
  GetMonthlyResultsUseCase(this._repo);

  final ResultsRepo _repo;

  Future<Result<MonthlyResultsEntity>> call(int childId) =>
      _repo.getMonthlyResults(childId);
}
