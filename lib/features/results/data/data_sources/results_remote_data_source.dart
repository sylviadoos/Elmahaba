import 'package:al_mahhaba_school/features/results/data/models/monthly_results_model.dart';
import 'package:al_mahhaba_school/features/results/data/models/result_details_model.dart';

/// Talks to the school system's results endpoints (signed in). Throws an
/// `AppException` on failure.
abstract interface class ResultsRemoteDataSource {
  Future<ResultDetailsModel> getResult({
    required int childId,
    required int resultId,
  });

  /// The child's monthly result sheets and the certificate they make.
  Future<MonthlyResultsModel> getMonthlyResults(int childId);
}
