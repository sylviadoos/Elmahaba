import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/results/data/data_sources/results_remote_data_source.dart';
import 'package:al_mahhaba_school/features/results/data/models/monthly_results_model.dart';
import 'package:al_mahhaba_school/features/results/data/repos/results_repo_impl.dart';

import '../../../../helpers/result_matchers.dart';
import '../../results_fixtures.dart';
import 'results_repo_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ResultsRemoteDataSource>()])
void main() {
  late MockResultsRemoteDataSource remoteDataSource;
  late ResultsRepoImpl repo;

  setUp(() {
    remoteDataSource = MockResultsRemoteDataSource();
    repo = ResultsRepoImpl(remoteDataSource);
  });

  test('getMonthlyResults: what the school sent', () async {
    final results = MonthlyResultsModel.fromJson(monthlyJson);
    when(
      remoteDataSource.getMonthlyResults(146),
    ).thenAnswer((_) async => results);

    expect(await repo.getMonthlyResults(146), isSuccess(results));
  });

  test('getMonthlyResults: can\'t reach it, fails with the error', () async {
    when(
      remoteDataSource.getMonthlyResults(any),
    ).thenThrow(const NetworkException());

    expect(await repo.getMonthlyResults(146), isFailure<NetworkException>());
  });
}
