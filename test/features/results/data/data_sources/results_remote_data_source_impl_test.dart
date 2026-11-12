import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/results/data/data_sources/results_remote_data_source_impl.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_kind.dart';

import '../../results_fixtures.dart';
import 'results_remote_data_source_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ApiService>()])
void main() {
  late MockApiService api;
  late ResultsRemoteDataSourceImpl dataSource;

  setUp(() {
    api = MockApiService();
    dataSource = ResultsRemoteDataSourceImpl(api);
  });

  void answerWith(List<Map<String, dynamic>> results) => when(
    api.get(any, queryParameters: anyNamed('queryParameters')),
  ).thenAnswer((_) async => resultsResponse(results));

  test('the months: asks for them by type, reads each in full', () async {
    answerWith([octoberJson]);

    final [result] = await dataSource.getResults(146, kind: ResultKind.monthly);

    verify(
      api.get(
        'v1/parent/children/146/results-v2',
        queryParameters: {'result_type': 'monthly'},
      ),
    ).called(1);
    expect(result.id, 820);
    expect(result.kind, ResultKind.monthly);
    expect(result.isMonthly, isTrue);
    expect(result.title, 'نتيجة شهر أكتوبر');
    expect(result.academicYear, '2026-2027');
    expect(result.resultType, 'value and color');
    expect(result.usesColors, isTrue);
    expect(result.period?.month, 10);
    expect(result.period?.monthName, 'October');
    expect(result.period?.monthNameAr, 'أكتوبر');
    expect(result.period?.year, 2026);
    expect(result.publishedAt, DateTime.utc(2026, 11, 11, 12));
    expect(result.finalResult, 245);
    expect(result.finalMax, 280);
    expect(result.rank, 3);
    expect(result.attendancePercentage, 96);
    expect(result.verdict, isNull);

    final arabic = result.subjectsIncluded.single;
    expect(arabic.name, 'Arabic');
    expect(arabic.total, 38);
    expect(arabic.maxTotal, 40);
    expect(arabic.components.first.name, 'Monthly exam');
    expect(arabic.components.first.mark, 14);
    expect(arabic.components.first.max, 15);
    expect(result.subjectsNotIncluded.single.name, 'Religion');
    expect(result.highLevel, isEmpty);
    expect(result.activities, isEmpty);
  });

  test('a term: no month, the school\'s word for it, the high level and '
      'the activities', () async {
    answerWith([firstTermJson]);

    final [term] = await dataSource.getResults(146, kind: ResultKind.term);

    verify(api.get(any, queryParameters: {'result_type': 'term'})).called(1);
    expect(term.kind, ResultKind.term);
    expect(term.period, isNull);
    expect(term.verdict, 'ناجح');
    // No total given: the counted subjects' marks together.
    expect(term.finalResult, 96);
    expect(term.finalMax, 100);
    expect(term.rank, isNull);

    final math = term.subjectsIncluded.single;
    expect(math.initialAssessment, 'F');
    expect(math.finalAssessment, 'F');
    expect(math.status, isNull);
    expect(term.subjectsNotIncluded.single.status, 'Pass');
    expect(term.highLevel.single.name, 'ICT');
    expect(term.activities.single.name, 'Sports');
    expect(term.activities.single.passed, isTrue);
  });

  test('a final result given as a mark: that mark, no word', () async {
    answerWith([
      {
        ...firstTermJson,
        'data': {
          ...firstTermJson['data'] as Map<String, dynamic>,
          'final_result': '297.4',
        },
      },
    ]);

    final [term] = await dataSource.getResults(146, kind: ResultKind.term);

    expect(term.finalResult, 297.4);
    expect(term.verdict, isNull);
  });

  test('none yet, or one without its id: left out', () async {
    answerWith([
      {'title': 'No id'},
    ]);

    expect(await dataSource.getResults(146, kind: ResultKind.term), isEmpty);
  });

  test('fails: the error goes on', () {
    when(
      api.get(any, queryParameters: anyNamed('queryParameters')),
    ).thenThrow(const NetworkException());

    expect(
      dataSource.getResults(146, kind: ResultKind.monthly),
      throwsA(isA<NetworkException>()),
    );
  });
}
