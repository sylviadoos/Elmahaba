import 'package:al_mahhaba_school/features/results/data/models/result_details_model.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_kind.dart';

/// Talks to the school system's results endpoints (signed in). Throws an
/// `AppException` on failure.
abstract interface class ResultsRemoteDataSource {
  /// The child's published results of this [kind] (monthly or term), in
  /// full, as the school lists them.
  Future<List<ResultDetailsModel>> getResults(
    int childId, {
    required ResultKind kind,
  });
}
