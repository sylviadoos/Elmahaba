import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_results_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/bloc/monthly_results_bloc.dart';
import 'package:al_mahhaba_school/features/results/presentation/bloc/monthly_results_intent.dart';
import 'package:al_mahhaba_school/features/results/presentation/bloc/monthly_results_state.dart';

import '../../../../helpers/result_dummy.dart';
import '../../results_fixtures.dart';
import '../../results_mocks.mocks.dart';

void main() {
  late MockGetMonthlyResultsUseCase getMonthly;

  setUpAll(() => provideResultDummy<MonthlyResultsEntity>());

  setUp(() => getMonthly = MockGetMonthlyResultsUseCase());

  MonthlyResultsBloc build() => MonthlyResultsBloc(getMonthly);

  final shown = MonthlyResultsState(
    childId: 146,
    results: BaseState.success(monthly),
    selectedKey: 'm1',
  );

  test('starts with no child', () {
    expect(build().state, const MonthlyResultsState());
  });

  blocTest<MonthlyResultsBloc, MonthlyResultsState>(
    'a child: loading, then their months with the newest picked',
    setUp: () =>
        when(getMonthly(146)).thenAnswer((_) async => Success(data: monthly)),
    build: build,
    act: (bloc) => bloc.add(const ShowChildMonthlyIntent(146)),
    expect: () => [
      const MonthlyResultsState(childId: 146, results: BaseState.loading()),
      shown,
    ],
    verify: (bloc) => expect(bloc.state.selectedMonth?.month, 'November'),
  );

  blocTest<MonthlyResultsBloc, MonthlyResultsState>(
    'another month picked',
    build: build,
    seed: () => shown,
    act: (bloc) => bloc.add(const SelectMonthIntent('m0')),
    expect: () => [
      MonthlyResultsState(
        childId: 146,
        results: BaseState.success(monthly),
        selectedKey: 'm0',
      ),
    ],
    verify: (bloc) => expect(bloc.state.selectedMonth?.month, 'October'),
  );

  blocTest<MonthlyResultsBloc, MonthlyResultsState>(
    'the child already shown: not asked again',
    build: build,
    seed: () => shown,
    act: (bloc) => bloc.add(const ShowChildMonthlyIntent(146)),
    expect: () => <MonthlyResultsState>[],
    verify: (_) => verifyZeroInteractions(getMonthly),
  );

  blocTest<MonthlyResultsBloc, MonthlyResultsState>(
    'couldn\'t load: the error, then asked again',
    setUp: () {
      var calls = 0;
      when(getMonthly(146)).thenAnswer(
        (_) async => calls++ == 0
            ? const Failure(exception: NetworkException())
            : Success(data: monthly),
      );
    },
    build: build,
    act: (bloc) async {
      bloc.add(const ShowChildMonthlyIntent(146));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ShowChildMonthlyIntent(146));
    },
    expect: () => [
      const MonthlyResultsState(childId: 146, results: BaseState.loading()),
      const MonthlyResultsState(
        childId: 146,
        results: BaseState.error(NetworkException()),
      ),
      const MonthlyResultsState(childId: 146, results: BaseState.loading()),
      shown,
    ],
  );
}
