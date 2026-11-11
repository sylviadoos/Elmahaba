import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/home/domain/repos/home_repo.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/repos/results_repo.dart';

/// The child's latest published result, in full, with what Home knows
/// about it: whether the parent has seen it, and the chat item that says
/// so. Null [details] before any result is published.
typedef LatestResult = ({
  ResultDetailsEntity details,
  bool isRead,
  String? chatKey,
});

/// The child's latest published result, in full; null before any is
/// published: `final latest = await getLatestResult(child.studentId);`
///
/// Home's dashboard says which result is the latest.
// TODO: use `v1/parent/children/{id}/results` instead, once its response
// is known — it lists them all.
@lazySingleton
class GetLatestResultUseCase {
  GetLatestResultUseCase(this._homeRepo, this._resultsRepo);

  final HomeRepo _homeRepo;
  final ResultsRepo _resultsRepo;

  Future<Result<LatestResult?>> call(int childId) async {
    final dashboard = await _homeRepo.getChildDashboard(childId);
    return dashboard.andThen<LatestResult?>((dashboard) async {
      final latest = dashboard.latestResult;
      if (latest == null) return const Success(data: null);
      // `results.items` is where "new" comes from on Home, and the one
      // under `results.latest` may say nothing about it.
      final listed = dashboard.results.items
          .where((result) => result.id == latest.id)
          .firstOrNull;
      final details = await _resultsRepo.getResult(
        childId: childId,
        resultId: latest.id,
      );
      return details.map(
        (details) => (
          details: details,
          isRead: listed?.isRead ?? latest.isRead,
          chatKey: listed?.chatKey ?? latest.chatKey,
        ),
      );
    });
  }
}
