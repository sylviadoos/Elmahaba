import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';

/// Never throws — errors come back as a `Failure`.
abstract interface class ResultsRepo {
  /// Every result published for the child with this `studentId`, months'
  /// and terms', newest first; empty before any.
  Future<Result<List<ResultDetailsEntity>>> getResults(int childId);
}
