import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';

/// Never throws — errors come back as a `Failure`.
abstract interface class ResultsRepo {
  /// A published result in full, for the child with this `studentId`.
  Future<Result<ResultDetailsEntity>> getResult({
    required int childId,
    required int resultId,
  });
}
