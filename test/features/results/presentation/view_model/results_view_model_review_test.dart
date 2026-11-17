import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/results/data/models/result_details_model.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_event.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_state.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_view_model.dart';

import '../../../../helpers/result_dummy.dart';
import '../../results_fixtures.dart';
import '../../results_mocks.mocks.dart';

/// Scenarios added by the Results review: what happens while the school is
/// still answering, what the parent can do to Results meanwhile, and how
/// many requests one opening really costs.
void main() {
  late MockGetResultsUseCase getResults;
  late MockMarkLatestResultReadUseCase markLatestRead;
  late ResultsViewModel viewModel;

  setUpAll(() {
    provideResultDummy<List<ResultDetailsEntity>>();
    provideResultDummy<void>();
  });

  setUp(() {
    getResults = MockGetResultsUseCase();
    markLatestRead = MockMarkLatestResultReadUseCase();
    when(
      markLatestRead(any),
    ).thenAnswer((_) async => const Success(data: null));
    when(getResults(any)).thenAnswer((_) async => Success(data: allResults));
    viewModel = ResultsViewModel(getResults, markLatestRead);
  });

  tearDown(() async {
    if (!viewModel.isClosed) await viewModel.close();
  });

  /// Lets every pending microtask run.
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 5));

  Future<void> load([int childId = 146]) async {
    await viewModel.doAction(LoadResultsEvent(childId));
    await settle();
  }

  group('opening Results', () {
    test(
      'the results load on their own, without anything being tapped',
      () async {
        await load();

        expect(viewModel.state.results.state, StateType.success);
        verify(getResults(146)).called(1);
      },
    );

    test(
      'the skeleton shows first, then the results — never an empty page',
      () async {
        final seen = <StateType>[];
        final listening = viewModel.stream.listen(
          (state) => seen.add(state.results.state),
        );
        addTearDown(listening.cancel);

        await load();

        expect(seen, [StateType.loading, StateType.success]);
      },
    );

    test(
      'one opening costs a results request and a dashboard one: the '
      'dashboard is fetched again only to see if the newest is unread',
      () async {
        await load();

        verify(getResults(146)).called(1);
        // `MarkLatestResultReadUseCase` asks Home's dashboard every time,
        // even when nothing is new.
        verify(markLatestRead(146)).called(1);
      },
    );
  });

  group('the parent leaves while the school is answering', () {
    test(
      'nothing is emitted after Results closes, and no error is thrown',
      () async {
        final pending = Completer<Result<List<ResultDetailsEntity>>>();
        when(getResults(146)).thenAnswer((_) => pending.future);
        final seen = <ResultsState>[];
        final errors = <Object>[];
        final listening = viewModel.stream.listen(
          seen.add,
          onError: errors.add,
        );

        unawaited(viewModel.doAction(const LoadResultsEvent(146)));
        await settle();
        await viewModel.close();
        // The school answers after the page is gone.
        pending.complete(Success(data: allResults));
        await settle();

        expect(errors, isEmpty);
        expect(seen.map((state) => state.results.state), [StateType.loading]);
        await listening.cancel();
      },
    );

    test('a refresh answering after it closed is dropped quietly', () async {
      await load();
      final pending = Completer<Result<List<ResultDetailsEntity>>>();
      when(getResults(146)).thenAnswer((_) => pending.future);

      unawaited(viewModel.doAction(const RefreshResultsEvent()));
      await settle();
      await viewModel.close();
      pending.complete(Success(data: [october]));
      await settle();

      // No "emit after close": the test would fail on the thrown error.
      expect(viewModel.isClosed, isTrue);
    });
  });

  group('asked again and again', () {
    test('pulled down five times while one request is out: one more request, '
        'not five', () async {
      await load();
      final pending = Completer<Result<List<ResultDetailsEntity>>>();
      when(getResults(146)).thenAnswer((_) => pending.future);

      for (var i = 0; i < 5; i++) {
        unawaited(viewModel.doAction(const RefreshResultsEvent()));
      }
      await settle();

      // The first load, then the one refresh the five folded into.
      verify(getResults(146)).called(2);
      pending.complete(Success(data: allResults));
      await settle();
    });

    test('refreshed when the school answers at once: nothing holds them '
        'back, so each one is its own request', () async {
      await load();

      for (var i = 0; i < 3; i++) {
        await viewModel.doAction(const RefreshResultsEvent());
      }
      await settle();

      // Recorded as it behaves today: the only guard is "one in flight".
      verify(getResults(146)).called(4);
    });

    test('a refresh asked while the first load is still out waits for it, '
        'then goes once — and the result published meanwhile shows', () async {
      final pending = Completer<Result<List<ResultDetailsEntity>>>();
      var calls = 0;
      when(getResults(146)).thenAnswer((_) {
        calls++;
        // The first load hangs; whatever is asked after it has November.
        return calls == 1
            ? pending.future
            : Future.value(Success(data: allResults));
      });

      unawaited(viewModel.doAction(const LoadResultsEvent(146)));
      await settle();
      expect(calls, 1, reason: 'the first load is on its way');

      // November is published and the notification arrives right now.
      await viewModel.doAction(const RefreshResultsEvent());
      await settle();
      expect(
        calls,
        1,
        reason:
            'nothing goes out while the load is in '
            'flight — it is remembered instead',
      );

      // The first load lands with what the school had before November.
      pending.complete(Success(data: [october, firstTerm]));
      await settle();

      expect(calls, 2, reason: 'the refresh it was holding went out, once');
      expect(viewModel.state.results.data, allResults);
      expect(viewModel.state.selected, november);
    });

    test('asked again many times while the first load is out: one request '
        'after it, not one per ask', () async {
      final pending = Completer<Result<List<ResultDetailsEntity>>>();
      var calls = 0;
      when(getResults(146)).thenAnswer((_) {
        calls++;
        return calls == 1
            ? pending.future
            : Future.value(Success(data: allResults));
      });

      unawaited(viewModel.doAction(const LoadResultsEvent(146)));
      await settle();
      // Five pushes and pulls while the skeleton is still up.
      for (var i = 0; i < 5; i++) {
        unawaited(viewModel.doAction(const RefreshResultsEvent()));
      }
      await settle();
      expect(calls, 1);

      pending.complete(Success(data: [october, firstTerm]));
      await settle();

      // The five folded into the one held back.
      expect(calls, 2);
      expect(viewModel.state.results.data, allResults);
    });

    test('nothing asked while it loaded: no extra request after it', () async {
      await load();

      verify(getResults(146)).called(1);
    });

    test('a refresh held back while the first load fails: it still goes, '
        'so a slow network doesn\'t strand the page', () async {
      final pending = Completer<Result<List<ResultDetailsEntity>>>();
      var calls = 0;
      when(getResults(146)).thenAnswer((_) {
        calls++;
        return calls == 1
            ? pending.future
            : Future.value(Success(data: allResults));
      });

      unawaited(viewModel.doAction(const LoadResultsEvent(146)));
      await settle();
      await viewModel.doAction(const RefreshResultsEvent());
      await settle();
      pending.complete(const Failure(exception: NetworkException()));
      await settle();

      // The held-back refresh finds the error and loads, as "Try again".
      expect(calls, 2);
      expect(viewModel.state.results.state, StateType.success);
      expect(viewModel.state.selected, november);
    });

    test('the parent picks another child while a refresh is held back: it '
        'is let go, not spent on the new child', () async {
      final pending = Completer<Result<List<ResultDetailsEntity>>>();
      when(getResults(146)).thenAnswer((_) => pending.future);
      when(getResults(147)).thenAnswer((_) async => Success(data: [firstTerm]));

      unawaited(viewModel.doAction(const LoadResultsEvent(146)));
      await settle();
      // Asked for child 146's results again.
      await viewModel.doAction(const RefreshResultsEvent());
      await settle();
      // Then child 147 is picked.
      await viewModel.doAction(const LoadResultsEvent(147));
      await settle();
      pending.complete(Success(data: allResults));
      await settle();

      expect(viewModel.state.childId, 147);
      expect(viewModel.state.results.data, [firstTerm]);
      // Child 147 was asked for once: the refresh meant for 146 was not
      // spent on them.
      verify(getResults(147)).called(1);
    });

    test(
      'Results closed while a refresh is held back: nothing is asked',
      () async {
        final pending = Completer<Result<List<ResultDetailsEntity>>>();
        when(getResults(146)).thenAnswer((_) => pending.future);

        unawaited(viewModel.doAction(const LoadResultsEvent(146)));
        await settle();
        await viewModel.doAction(const RefreshResultsEvent());
        await settle();
        await viewModel.close();
        pending.complete(Success(data: allResults));
        await settle();

        // Only the first load: the page is gone, so nothing follows it.
        verify(getResults(146)).called(1);
      },
    );
  });

  group('another child picked meanwhile', () {
    test('the first child\'s answer is dropped, and theirs shows', () async {
      final pending = Completer<Result<List<ResultDetailsEntity>>>();
      when(getResults(146)).thenAnswer((_) => pending.future);
      when(getResults(147)).thenAnswer((_) async => Success(data: [firstTerm]));

      unawaited(viewModel.doAction(const LoadResultsEvent(146)));
      await settle();
      await viewModel.doAction(const LoadResultsEvent(147));
      await settle();
      pending.complete(Success(data: allResults));
      await settle();

      expect(viewModel.state.childId, 147);
      expect(viewModel.state.results.data, [firstTerm]);
      expect(viewModel.state.selected, firstTerm);
    });

    test('a refresh answering for the child before is dropped', () async {
      await load();
      await viewModel.doAction(SelectResultEvent(october.id));
      final pending = Completer<Result<List<ResultDetailsEntity>>>();
      when(getResults(146)).thenAnswer((_) => pending.future);
      when(getResults(147)).thenAnswer((_) async => Success(data: [firstTerm]));

      unawaited(viewModel.doAction(const RefreshResultsEvent()));
      await settle();
      await viewModel.doAction(const LoadResultsEvent(147));
      await settle();
      pending.complete(Success(data: [november]));
      await settle();

      expect(viewModel.state.childId, 147);
      expect(viewModel.state.results.data, [firstTerm]);
    });
  });

  group('what\'s shown while the new answer is on its way', () {
    test('the old results stay on screen — no skeleton, no blank', () async {
      await load();
      final pending = Completer<Result<List<ResultDetailsEntity>>>();
      when(getResults(146)).thenAnswer((_) => pending.future);

      unawaited(viewModel.doAction(const RefreshResultsEvent()));
      await settle();

      expect(viewModel.state.results.state, StateType.success);
      expect(viewModel.state.results.data, allResults);
      pending.complete(Success(data: allResults));
      await settle();
    });

    test('the one picked in the filter survives a refresh that brings '
        'nothing new', () async {
      await load();
      await viewModel.doAction(SelectResultEvent(firstTerm.id));

      await viewModel.doAction(const RefreshResultsEvent());
      await settle();

      expect(viewModel.state.selected, firstTerm);
    });

    test('the newest result withdrawn at school: the one the parent picked '
        'stays, and nothing is reported seen', () async {
      await load();
      await viewModel.doAction(SelectResultEvent(firstTerm.id));
      clearInteractions(markLatestRead);
      // November is taken down again.
      when(
        getResults(146),
      ).thenAnswer((_) async => Success(data: [october, firstTerm]));

      await viewModel.doAction(const RefreshResultsEvent());
      await settle();

      // Nothing was published: October was already there, under November.
      expect(viewModel.state.selected, firstTerm);
      expect(viewModel.state.results.data, [october, firstTerm]);
      verifyNever(markLatestRead(any));
    });

    test('the newest withdrawn while the parent is on it: the newest left '
        'shows, without being called new', () async {
      await load();
      expect(viewModel.state.selected, november);
      clearInteractions(markLatestRead);
      when(
        getResults(146),
      ).thenAnswer((_) async => Success(data: [october, firstTerm]));

      await viewModel.doAction(const RefreshResultsEvent());
      await settle();

      // The one they were reading is gone, so the newest left shows.
      expect(viewModel.state.selected, october);
      verifyNever(markLatestRead(any));
    });

    test('one withdrawn and another published at once: the new one shows, '
        'as a publish', () async {
      final december = ResultDetailsModel.fromJson({
        'result_id': 980,
        'result_type': 'monthly',
        'title': 'نتيجة شهر ديسمبر',
        'academic_year': '2026-2027',
        'published_at': '2027-01-05T09:00:00+00:00',
        'data': const <String, dynamic>{},
      });
      await load();
      await viewModel.doAction(SelectResultEvent(firstTerm.id));
      clearInteractions(markLatestRead);
      // November goes, December arrives.
      when(
        getResults(146),
      ).thenAnswer((_) async => Success(data: [december, october, firstTerm]));

      await viewModel.doAction(const RefreshResultsEvent());
      await settle();

      expect(viewModel.state.selected, december);
      verify(markLatestRead(146)).called(1);
    });

    test('a result published late for an earlier month: still a publish, '
        'so it shows', () async {
      when(
        getResults(146),
      ).thenAnswer((_) async => Success(data: [october, firstTerm]));
      await load();
      await viewModel.doAction(SelectResultEvent(firstTerm.id));
      clearInteractions(markLatestRead);
      // September's sheet is uploaded now, so it sorts newest.
      final september = ResultDetailsModel.fromJson({
        'result_id': 700,
        'result_type': 'monthly',
        'title': 'نتيجة شهر سبتمبر',
        'academic_year': '2026-2027',
        'period': const {'month': 9, 'month_name': 'September', 'year': 2026},
        'published_at': '2026-12-20T08:00:00+00:00',
        'data': const <String, dynamic>{},
      });
      when(
        getResults(146),
      ).thenAnswer((_) async => Success(data: [september, october, firstTerm]));

      await viewModel.doAction(const RefreshResultsEvent());
      await settle();

      expect(viewModel.state.selected, september);
      verify(markLatestRead(146)).called(1);
    });

    test('the newest edited and sent again under its own id: not a new '
        'one, so the parent\'s pick is left alone', () async {
      await load();
      await viewModel.doAction(SelectResultEvent(october.id));
      clearInteractions(markLatestRead);
      // The school corrects November's marks; its id doesn't change.
      final corrected = ResultDetailsModel.fromJson({
        ...novemberJson,
        'data': {
          ...novemberJson['data']! as Map<String, dynamic>,
          'grand_total': 250,
        },
      });
      when(
        getResults(146),
      ).thenAnswer((_) async => Success(data: [corrected, october, firstTerm]));

      await viewModel.doAction(const RefreshResultsEvent());
      await settle();

      expect(viewModel.state.selected, october);
      expect(viewModel.state.results.data?.first.finalResult, 250);
      verifyNever(markLatestRead(any));
    });

    test(
      'every result withdrawn: the empty page, and the pick is let go',
      () async {
        await load();
        when(getResults(146)).thenAnswer((_) async => const Success(data: []));

        await viewModel.doAction(const RefreshResultsEvent());
        await settle();

        expect(viewModel.state.results.state, StateType.success);
        expect(viewModel.state.selected, isNull);
      },
    );
  });

  group('errors', () {
    test('no internet on the first load: the error, nothing shown', () async {
      when(
        getResults(146),
      ).thenAnswer((_) async => const Failure(exception: NetworkException()));

      await load();

      expect(viewModel.state.results.state, StateType.error);
      expect(viewModel.state.results.exception, isA<NetworkException>());
      expect(viewModel.state.selected, isNull);
      verifyNever(markLatestRead(any));
    });

    test('a timeout reads as no internet, so "Try again" is offered', () async {
      when(
        getResults(146),
      ).thenAnswer((_) async => const Failure(exception: NetworkException()));

      await load();

      expect(viewModel.state.results.exception, isA<NetworkException>());
    });

    test(
      'the session ended: the error says so, so "Log in" is offered',
      () async {
        when(getResults(146)).thenAnswer(
          (_) async => const Failure(exception: UnauthorizedException()),
        );

        await load();

        expect(viewModel.state.results.exception, isA<UnauthorizedException>());
      },
    );

    test('a 500: the error keeps its status for the message', () async {
      when(getResults(146)).thenAnswer(
        (_) async => const Failure(
          exception: ServerException(statusCode: 500, message: 'Server Error'),
        ),
      );

      await load();

      expect(viewModel.state.results.exception?.statusCode, 500);
      expect(viewModel.state.results.exception?.message, 'Server Error');
    });

    test(
      'pulled down after it failed: it loads again, as "Try again"',
      () async {
        when(
          getResults(146),
        ).thenAnswer((_) async => const Failure(exception: NetworkException()));
        await load();
        when(
          getResults(146),
        ).thenAnswer((_) async => Success(data: allResults));

        await viewModel.doAction(const RefreshResultsEvent());
        await settle();

        expect(viewModel.state.selected, november);
      },
    );

    test('"Try again" while it is already trying: not asked twice', () async {
      when(
        getResults(146),
      ).thenAnswer((_) async => const Failure(exception: NetworkException()));
      await load();
      final pending = Completer<Result<List<ResultDetailsEntity>>>();
      when(getResults(146)).thenAnswer((_) => pending.future);

      unawaited(viewModel.doAction(const LoadResultsEvent(146)));
      await settle();
      unawaited(viewModel.doAction(const LoadResultsEvent(146)));
      await settle();

      // The first failed load, then the one retry.
      verify(getResults(146)).called(2);
      pending.complete(Success(data: allResults));
      await settle();
    });
  });

  group('marking the newest seen', () {
    test(
      'nothing published: nothing is marked, and no dashboard request',
      () async {
        when(getResults(146)).thenAnswer((_) async => const Success(data: []));

        await load();

        verifyNever(markLatestRead(any));
      },
    );

    test(
      'it fails: the results stay on screen, tried again next time',
      () async {
        when(
          markLatestRead(any),
        ).thenAnswer((_) async => const Failure(exception: NetworkException()));

        await load();

        expect(viewModel.state.results.state, StateType.success);
        expect(viewModel.state.selected, november);
      },
    );

    test('the same child opened again: not loaded or marked twice', () async {
      await load();
      await load();

      verify(getResults(146)).called(1);
      verify(markLatestRead(146)).called(1);
    });

    test('a refresh with nothing new: not marked again', () async {
      await load();
      clearInteractions(markLatestRead);

      await viewModel.doAction(const RefreshResultsEvent());
      await settle();

      verifyNever(markLatestRead(any));
    });

    test('the parent goes to another child and comes back: the school is '
        'not told twice about the same result', () async {
      when(getResults(147)).thenAnswer((_) async => Success(data: [firstTerm]));

      await load();
      await load(147);
      clearInteractions(markLatestRead);

      // Back to the first child, whose results load again.
      await load();

      expect(viewModel.state.selected, november);
      // November was already reported on the first visit: the dashboard
      // is not fetched a second time for it.
      verifyNever(markLatestRead(146));
    });

    test('each child is remembered on their own', () async {
      when(getResults(147)).thenAnswer((_) async => Success(data: [firstTerm]));

      await load();
      await load(147);

      verify(markLatestRead(146)).called(1);
      verify(markLatestRead(147)).called(1);
    });

    test(
      'a result published later: the school is told about that one',
      () async {
        when(
          getResults(146),
        ).thenAnswer((_) async => Success(data: [october, firstTerm]));
        await load();
        clearInteractions(markLatestRead);

        // November is published while Results is open.
        when(
          getResults(146),
        ).thenAnswer((_) async => Success(data: allResults));
        await viewModel.doAction(const RefreshResultsEvent());
        await settle();

        // A different result than the one remembered, so it is reported.
        expect(viewModel.state.selected, november);
        verify(markLatestRead(146)).called(1);
      },
    );

    test('telling the school failed: it is tried again next time, not '
        'remembered as done', () async {
      when(
        markLatestRead(any),
      ).thenAnswer((_) async => const Failure(exception: NetworkException()));
      await load();
      verify(markLatestRead(146)).called(1);

      // The parent leaves to another child and comes back.
      when(getResults(147)).thenAnswer((_) async => Success(data: [firstTerm]));
      await load(147);
      when(
        markLatestRead(any),
      ).thenAnswer((_) async => const Success(data: null));
      await load();

      // Not written off: the failure left nothing remembered.
      verify(markLatestRead(146)).called(1);
    });
  });

  test('no pagination: every result comes in one answer, so there is no '
      'page to load', () async {
    await load();

    expect(viewModel.state.results.data, hasLength(allResults.length));
    verify(getResults(146)).called(1);
  });
}
