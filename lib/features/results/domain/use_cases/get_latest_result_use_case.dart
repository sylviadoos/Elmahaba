import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/home/domain/repos/home_repo.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/repos/results_repo.dart';

/// The child's latest published result, in full; null before any is
/// published: `final result = await getLatestResult(child.studentId);`
///
/// Home's dashboard says which result is the latest.
// TODO: use `v1/parent/children/{id}/results` instead, once its response
// is known — it lists them all.
@lazySingleton
class GetLatestResultUseCase {
  GetLatestResultUseCase(this._homeRepo, this._resultsRepo);

  final HomeRepo _homeRepo;
  final ResultsRepo _resultsRepo;

  Future<Result<ResultDetailsEntity?>> call(int childId) async {
    final dashboard = await _homeRepo.getChildDashboard(childId);
    return dashboard.andThen<ResultDetailsEntity?>((dashboard) async {
      final latest = dashboard.latestResult;
      if (latest == null) return const Success(data: null);
      return _resultsRepo.getResult(childId: childId, resultId: latest.id);
    });
  }
}
