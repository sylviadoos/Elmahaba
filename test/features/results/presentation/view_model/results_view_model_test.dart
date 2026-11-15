import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_event.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_view_model.dart';

import '../../../../helpers/result_dummy.dart';
import '../../results_fixtures.dart';
import '../../results_mocks.mocks.dart';

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

  tearDown(() => viewModel.close());

  /// Loads [omar]'s, and lets the marking that follows run.
  Future<void> load([int childId = 146]) async {
    await viewModel.doAction(LoadResultsEvent(childId));
    await Future<void>.delayed(Duration.zero);
  }

  test('the newest shows first, and Home stops calling it new', () async {
    await load();

    expect(viewModel.state.results.state, StateType.success);
    expect(viewModel.state.results.data, allResults);
    expect(viewModel.state.selected, november);
    verify(markLatestRead(146)).called(1);
  });

  test('another picked in the filter shows instead', () async {
    await load();

    await viewModel.doAction(SelectResultEvent(firstTerm.id));

    expect(viewModel.state.selected, firstTerm);
  });

  test('a month\'s certificate has every month of its year, oldest first; '
      'a term\'s none', () async {
    await load();

    expect(viewModel.state.certificateMonths, [october, november]);
    await viewModel.doAction(SelectResultEvent(october.id));
    expect(viewModel.state.certificateMonths, [october, november]);
    await viewModel.doAction(SelectResultEvent(firstTerm.id));
    expect(viewModel.state.certificateMonths, isEmpty);
  });

  test('none published: nothing shown, nothing marked', () async {
    when(getResults(any)).thenAnswer((_) async => const Success(data: []));

    await load();

    expect(viewModel.state.results.state, StateType.success);
    expect(viewModel.state.selected, isNull);
    verifyNever(markLatestRead(any));
  });

  test('the same child again: not loaded twice', () async {
    await load();
    await load();

    verify(getResults(146)).called(1);
  });

  test('another child: theirs, the newest first again', () async {
    await load();
    await viewModel.doAction(SelectResultEvent(firstTerm.id));

    await load(147);

    verify(getResults(147)).called(1);
    expect(viewModel.state.childId, 147);
    expect(viewModel.state.selected, november);
  });

  test('fails: the error, and "Try again" loads again', () async {
    when(
      getResults(any),
    ).thenAnswer((_) async => const Failure(exception: NetworkException()));

    await load();

    expect(viewModel.state.results.state, StateType.error);
    expect(viewModel.state.results.exception, isA<NetworkException>());

    when(getResults(any)).thenAnswer((_) async => Success(data: allResults));
    await load();

    expect(viewModel.state.selected, november);
  });

  group('asked again', () {
    test(
      'November published since: it shows, and Home stops calling it new',
      () async {
        // Opened before November's sheet was uploaded.
        when(
          getResults(any),
        ).thenAnswer((_) async => Success(data: [october, firstTerm]));
        await load();
        await viewModel.doAction(SelectResultEvent(firstTerm.id));
        clearInteractions(markLatestRead);

        when(
          getResults(any),
        ).thenAnswer((_) async => Success(data: allResults));
        await viewModel.doAction(const RefreshResultsEvent());
        await Future<void>.delayed(Duration.zero);

        expect(viewModel.state.results.data, allResults);
        expect(viewModel.state.selected, november);
        verify(markLatestRead(146)).called(1);
      },
    );

    test('nothing new: the one picked stays, no skeleton meanwhile', () async {
      await load();
      await viewModel.doAction(SelectResultEvent(firstTerm.id));
      clearInteractions(markLatestRead);
      final states = <StateType>[];
      final listening = viewModel.stream.listen(
        (state) => states.add(state.results.state),
      );
      addTearDown(listening.cancel);

      await viewModel.doAction(const RefreshResultsEvent());
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.selected, firstTerm);
      expect(states, isNot(contains(StateType.loading)));
      verify(getResults(146)).called(2);
      verifyNever(markLatestRead(any));
    });

    test('it fails: what was shown stays', () async {
      await load();
      when(
        getResults(any),
      ).thenAnswer((_) async => const Failure(exception: NetworkException()));

      await viewModel.doAction(const RefreshResultsEvent());

      expect(viewModel.state.results.state, StateType.success);
      expect(viewModel.state.selected, november);
    });

    test('it hadn\'t loaded: loaded, as "Try again"', () async {
      when(
        getResults(any),
      ).thenAnswer((_) async => const Failure(exception: NetworkException()));
      await load();
      when(getResults(any)).thenAnswer((_) async => Success(data: allResults));

      await viewModel.doAction(const RefreshResultsEvent());

      expect(viewModel.state.selected, november);
    });

    test('no child yet: nothing asked', () async {
      await viewModel.doAction(const RefreshResultsEvent());

      verifyNever(getResults(any));
    });
  });

  test('marking it read fails: the results stay', () async {
    when(
      markLatestRead(any),
    ).thenAnswer((_) async => const Failure(exception: NetworkException()));

    await load();

    expect(viewModel.state.results.state, StateType.success);
  });
}
