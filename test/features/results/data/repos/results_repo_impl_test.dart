import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/results/data/data_sources/results_remote_data_source.dart';
import 'package:al_mahhaba_school/features/results/data/models/result_details_model.dart';
import 'package:al_mahhaba_school/features/results/data/repos/results_repo_impl.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_kind.dart';

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

  void answer(ResultKind kind, List<Map<String, dynamic>> results) => when(
    remoteDataSource.getResults(any, kind: kind),
  ).thenAnswer((_) async => results.map(ResultDetailsModel.fromJson).toList());

  test('the months and the terms together, newest first', () async {
    answer(ResultKind.monthly, [octoberJson, novemberJson]);
    answer(ResultKind.term, [firstTermJson]);

    final result = await repo.getResults(146);

    verify(remoteDataSource.getResults(146, kind: ResultKind.monthly));
    verify(remoteDataSource.getResults(146, kind: ResultKind.term));
    expect(result, isSuccess(allResults));
  });

  test('none published: empty', () async {
    answer(ResultKind.monthly, []);
    answer(ResultKind.term, []);

    expect(await repo.getResults(146), isSuccess(isEmpty));
  });

  test('one of them can\'t be reached: fails with its error', () async {
    answer(ResultKind.monthly, [octoberJson]);
    when(
      remoteDataSource.getResults(any, kind: ResultKind.term),
    ).thenThrow(const NetworkException());

    expect(await repo.getResults(146), isFailure<NetworkException>());
  });
}
