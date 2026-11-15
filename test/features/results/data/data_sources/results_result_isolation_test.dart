import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/features/results/data/data_sources/results_remote_data_source_impl.dart';
import 'package:al_mahhaba_school/features/results/data/repos/results_repo_impl.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_kind.dart';

import '../../../../helpers/result_matchers.dart';
import '../../results_fixtures.dart';
import 'results_remote_data_source_impl_test.mocks.dart';

/// One result the school sends in a shape the app can't read must cost
/// only itself: every other result the child has still reaches the parent,
/// and what was dropped is written to the log rather than swallowed.
void main() {
  late MockApiService api;
  late ResultsRemoteDataSourceImpl dataSource;
  late List<String> logged;
  late DebugPrintCallback originalDebugPrint;

  setUp(() {
    api = MockApiService();
    dataSource = ResultsRemoteDataSourceImpl(api);
    logged = [];
    originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      if (message != null) logged.add(message);
    };
  });

  tearDown(() => debugPrint = originalDebugPrint);

  void answerWith(List<Object?> results) => when(
    api.get(any, queryParameters: anyNamed('queryParameters')),
  ).thenAnswer(
    (_) async => {'status': 'success', 'data': results, 'meta': const {}},
  );

  Future<List<int>> idsOf(ResultKind kind) async =>
      (await dataSource.getResults(146, kind: kind))
          .map((result) => result.id)
          .toList();

  group('a result without a usable id', () {
    test('is left out, and the good ones beside it still come', () async {
      answerWith([
        octoberJson,
        {'title': 'No id at all'},
        novemberJson,
      ]);

      expect(await idsOf(ResultKind.monthly), [820, 905]);
    });

    test('an id sent as text is left out too — it couldn\'t be opened', ()
        async {
      answerWith([
        {...octoberJson, 'result_id': '820'},
        novemberJson,
      ]);

      expect(await idsOf(ResultKind.monthly), [905]);
    });

    test('the log says one was left out and why', () async {
      answerWith([
        {'title': 'No id at all'},
        {...novemberJson, 'result_id': 9.5},
      ]);

      await dataSource.getResults(146, kind: ResultKind.monthly);

      expect(logged, hasLength(2));
      expect(logged.first, contains('left out'));
      expect(logged.first, contains('missing'));
      expect(logged.last, contains('double, not an int'));
    });
  });

  group('results the school sends oddly', () {
    test('every shape of "data" is read, none of them throws', () async {
      answerWith([
        octoberJson,
        {'result_id': 1, 'data': const <dynamic>[]},
        {'result_id': 2, 'data': 'nonsense'},
        {'result_id': 3, 'data': 42},
        {'result_id': 4, 'data': null},
        {'result_id': 5},
        novemberJson,
      ]);

      expect(await idsOf(ResultKind.monthly), [820, 1, 2, 3, 4, 5, 905]);
      expect(logged, isEmpty, reason: 'none of these had to be dropped');
    });

    test('odd flags and types inside a result don\'t drop it', () async {
      answerWith([
        {
          'result_id': 7,
          'result_type': 99,
          'title': 123,
          'published_at': 'not a date',
          'period': 'not an object',
          'data': {
            'subjects': [
              {'name': 'Arabic', 'included_in_total': 1, 'total': '38'},
              {'name': 'Religion', 'included_in_total': 'no', 'total': 40},
            ],
            'rank': '3',
            'grand_total': null,
          },
        },
      ]);

      final [result] = await dataSource.getResults(
        146,
        kind: ResultKind.monthly,
      );

      expect(result.id, 7);
      expect(result.kind, ResultKind.other);
      expect(result.title, isEmpty);
      expect(result.publishedAt, isNull);
      expect(result.period, isNull);
      expect(result.rank, 3);
      expect(result.subjectsIncluded.single.name, 'Arabic');
      expect(result.subjectsIncluded.single.total, 38);
      expect(result.subjectsNotIncluded.single.name, 'Religion');
      expect(logged, isEmpty);
    });

    test('nulls and non-objects in the list are skipped without a word', ()
        async {
      answerWith([null, 'nonsense', 42, octoberJson]);

      expect(await idsOf(ResultKind.monthly), [820]);
      // They never looked like results, so there is nothing to report.
      expect(logged, isEmpty);
    });
  });

  test('the whole page survives: the repo still succeeds with the results '
      'it could read', () async {
    answerWith([
      octoberJson,
      {'title': 'No id'},
      {'result_id': 1, 'data': const <dynamic>[]},
      firstTermJson,
    ]);
    final repo = ResultsRepoImpl(dataSource);

    final result = await repo.getResults(146);

    expect(result, isSuccess<List<Object?>>(isNotEmpty));
    // The months and the terms are asked for separately, and this server
    // answers both with the same list: the one without an id is reported
    // each time it is seen, and never silently.
    expect(logged, hasLength(2));
    expect(logged, everyElement(contains('left out')));
  });
}
