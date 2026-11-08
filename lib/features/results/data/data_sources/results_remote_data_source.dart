import 'package:al_mahhaba_school/features/results/data/models/result_details_model.dart';

/// Talks to the school system's results endpoints (signed in). Throws an
/// `AppException` on failure.
abstract interface class ResultsRemoteDataSource {
  /// A published result in full: every subject's mark and its parts, and
  /// the activities. [childId] is the child's `student_id`.
  Future<ResultDetailsModel> getResult({
    required int childId,
    required int resultId,
  });
}
