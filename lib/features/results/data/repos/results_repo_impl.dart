import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/results/data/data_sources/results_remote_data_source.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_kind.dart';
import 'package:al_mahhaba_school/features/results/domain/repos/results_repo.dart';

@LazySingleton(as: ResultsRepo)
class ResultsRepoImpl implements ResultsRepo {
  ResultsRepoImpl(this._remoteDataSource);

  final ResultsRemoteDataSource _remoteDataSource;

  /// Asked for by kind, both at once: the months must all be there for the
  /// certificate.
  @override
  Future<Result<List<ResultDetailsEntity>>> getResults(int childId) =>
      Result.guard(() async {
        // Future.wait, not a record's `.wait`: a failure stays the
        // AppException it was, not a ParallelWaitError.
        final byKind = await Future.wait([
          _remoteDataSource.getResults(childId, kind: ResultKind.monthly),
          _remoteDataSource.getResults(childId, kind: ResultKind.term),
        ]);
        final all = <ResultDetailsEntity>[for (final list in byKind) ...list];
        // Newest first; one that doesn't say when, last.
        final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
        all.sort(
          (a, b) => (b.publishedAt ?? epoch).compareTo(a.publishedAt ?? epoch),
        );
        return all;
      });
}
