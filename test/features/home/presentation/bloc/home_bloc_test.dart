import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/attendance_counts_entity.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/holiday_entity.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/month_attendance_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/home_bloc.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/home_intent.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/home_state.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../chat/chat_mocks.mocks.dart';
import '../../home_fixtures.dart';
import '../../home_mocks.mocks.dart';

void main() {
  late MockGetChildDashboardUseCase getDashboard;
  late MockGetMonthAttendanceUseCase getMonth;
  late StreamController<int> reads;

  final first = dashboardWith();
  // Something changed at school: one more absence.
  final changed = dashboardWith(absences: 2);
  final other = dashboardWith(homework: const []);
  // The parent read what was new.
  final read = dashboardWith(absences: 3);

  setUpAll(() {
    provideResultDummy<ChildDashboardEntity>();
    // Not answered: the Today card goes without it.
    provideResultDummy<MonthAttendanceEntity>();
  });

  setUp(() {
    getDashboard = MockGetChildDashboardUseCase();
    getMonth = MockGetMonthAttendanceUseCase();
    reads = StreamController.broadcast();
    addTearDown(reads.close);
  });

  HomeBloc build() {
    final watchReads = MockWatchChatReadsUseCase();
    when(watchReads()).thenAnswer((_) => reads.stream);
    return HomeBloc(getDashboard, getMonth, watchReads);
  }

  void answer(int childId, ChildDashboardEntity dashboard) => when(
    getDashboard(childId),
  ).thenAnswer((_) async => Success(data: dashboard));

  void fail(int childId) => when(
    getDashboard(childId),
  ).thenAnswer((_) async => const Failure(exception: NetworkException()));

  HomeState shown(
    int childId,
    ChildDashboardEntity dashboard, {
    bool isRefreshing = false,
  }) => HomeState(
    childId: childId,
    dashboard: BaseState.success(dashboard),
    isRefreshing: isRefreshing,
  );

  test('starts with no child', () => expect(build().state, const HomeState()));

  blocTest<HomeBloc, HomeState>(
    'a child: the skeleton, then their dashboard',
    setUp: () => answer(1, first),
    build: build,
    act: (bloc) => bloc.add(const ShowChildIntent(1)),
    expect: () => [
      const HomeState(childId: 1, dashboard: BaseState.loading()),
      shown(1, first),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'the child already shown: not asked again',
    build: build,
    seed: () => shown(1, first),
    act: (bloc) => bloc.add(const ShowChildIntent(1)),
    expect: () => <HomeState>[],
    verify: (_) => verifyNever(getDashboard(any)),
  );

  blocTest<HomeBloc, HomeState>(
    'another child: theirs replaces it',
    setUp: () => answer(2, other),
    build: build,
    seed: () => shown(1, first),
    act: (bloc) => bloc.add(const ShowChildIntent(2)),
    expect: () => [
      const HomeState(childId: 2, dashboard: BaseState.loading()),
      shown(2, other),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'refreshed: what\'s shown stays until the new one comes',
    setUp: () => answer(1, changed),
    build: build,
    seed: () => shown(1, first),
    act: (bloc) => bloc.add(const RefreshHomeIntent()),
    expect: () => [shown(1, first, isRefreshing: true), shown(1, changed)],
  );

  blocTest<HomeBloc, HomeState>(
    'a refresh that fails: what\'s shown stays, quietly',
    setUp: () => fail(1),
    build: build,
    seed: () => shown(1, first),
    act: (bloc) => bloc.add(const RefreshHomeIntent()),
    expect: () => [shown(1, first, isRefreshing: true), shown(1, first)],
  );

  late Completer<Result<ChildDashboardEntity>> pending;

  blocTest<HomeBloc, HomeState>(
    'asked again while it\'s asking: once more, after it answers',
    setUp: () {
      pending = Completer();
      var calls = 0;
      when(getDashboard(1)).thenAnswer(
        (_) =>
            calls++ == 0 ? pending.future : Future.value(Success(data: read)),
      );
    },
    build: build,
    seed: () => shown(1, first),
    act: (bloc) async {
      bloc.add(const RefreshHomeIntent());
      await Future<void>.delayed(Duration.zero);
      // Notifications while the first is on its way: it may be from before.
      bloc
        ..add(const RefreshHomeIntent())
        ..add(const RefreshHomeIntent());
      await Future<void>.delayed(Duration.zero);
      pending.complete(Success(data: changed));
    },
    expect: () => [
      shown(1, first, isRefreshing: true),
      shown(1, changed),
      shown(1, changed, isRefreshing: true),
      shown(1, read),
    ],
    verify: (_) => verify(getDashboard(1)).called(2),
  );

  blocTest<HomeBloc, HomeState>(
    'the school confirmed a read: asked again, even when Home is '
    'underneath and asking already (back from the chat, both go together)',
    setUp: () {
      pending = Completer();
      var calls = 0;
      when(getDashboard(1)).thenAnswer(
        (_) =>
            calls++ == 0 ? pending.future : Future.value(Success(data: read)),
      );
    },
    build: build,
    seed: () => shown(1, first),
    act: (bloc) async {
      // Back on Home: its refresh goes as the chat marks what was seen.
      bloc.add(const RefreshHomeIntent());
      await Future<void>.delayed(Duration.zero);
      reads.add(0);
      await Future<void>.delayed(Duration.zero);
      // The school answered Home before it saved the read.
      pending.complete(Success(data: first));
    },
    expect: () => [
      shown(1, first, isRefreshing: true),
      shown(1, first),
      shown(1, first, isRefreshing: true),
      shown(1, read),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'a read confirmed, nothing on its way: asked again',
    setUp: () => answer(1, read),
    build: build,
    seed: () => shown(1, first),
    act: (_) => reads.add(0),
    expect: () => [shown(1, first, isRefreshing: true), shown(1, read)],
  );

  blocTest<HomeBloc, HomeState>(
    'couldn\'t load: the error, then "Try again" loads it',
    setUp: () {
      var calls = 0;
      when(getDashboard(1)).thenAnswer(
        (_) async => calls++ == 0
            ? const Failure(exception: NetworkException())
            : Success(data: first),
      );
    },
    build: build,
    act: (bloc) async {
      bloc.add(const ShowChildIntent(1));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const RefreshHomeIntent());
    },
    expect: () => [
      const HomeState(childId: 1, dashboard: BaseState.loading()),
      const HomeState(
        childId: 1,
        dashboard: BaseState.error(NetworkException()),
      ),
      const HomeState(childId: 1, dashboard: BaseState.loading()),
      shown(1, first),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'no child yet: nothing to refresh',
    build: build,
    act: (bloc) => bloc.add(const RefreshHomeIntent()),
    expect: () => <HomeState>[],
    verify: (_) => verifyNever(getDashboard(any)),
  );

  blocTest<HomeBloc, HomeState>(
    'an answer for the child picked before is dropped',
    setUp: () {
      final late = Completer<Result<ChildDashboardEntity>>();
      when(getDashboard(1)).thenAnswer((_) => late.future);
      when(getDashboard(2)).thenAnswer((_) async {
        // Child 1's comes after child 2 was picked.
        Future<void>.delayed(
          Duration.zero,
          () => late.complete(Success(data: first)),
        );
        return Success(data: other);
      });
    },
    build: build,
    act: (bloc) async {
      bloc
        ..add(const ShowChildIntent(1))
        ..add(const ShowChildIntent(2));
      await Future<void>.delayed(const Duration(milliseconds: 10));
    },
    expect: () => [
      const HomeState(childId: 1, dashboard: BaseState.loading()),
      const HomeState(childId: 2, dashboard: BaseState.loading()),
      shown(2, other),
    ],
  );

  group('today'
      's holiday or day off', () {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final calendar = MonthAttendanceEntity(
      month: thisMonth,
      counts: const AttendanceCountsEntity(
        presentDays: 0,
        absentDays: 0,
        excusedDays: 0,
      ),
      records: const [],
      holidays: [
        HolidayEntity(date: now, name: '6 October', nameAr: '6 أكتوبر'),
      ],
      weekendWeekdays: const {DateTime.friday, DateTime.saturday},
    );

    void answerMonth(int childId) => when(
      getMonth(childId: childId, month: anyNamed('month')),
    ).thenAnswer((_) async => Success(data: calendar));

    blocTest<HomeBloc, HomeState>(
      'this month'
      's, asked with the dashboard',
      setUp: () {
        answer(1, first);
        answerMonth(1);
      },
      build: build,
      act: (bloc) => bloc.add(const ShowChildIntent(1)),
      verify: (bloc) {
        verify(getMonth(childId: 1, month: thisMonth)).called(1);
        expect(bloc.state.calendar, calendar);
        expect(bloc.state.dashboard.data, first);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'refreshed the same month: not asked again',
      setUp: () {
        answer(1, first);
        answerMonth(1);
      },
      build: build,
      act: (bloc) async {
        bloc.add(const ShowChildIntent(1));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const RefreshHomeIntent());
      },
      verify: (_) {
        verify(getMonth(childId: 1, month: thisMonth)).called(1);
        verify(getDashboard(1)).called(2);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'another child: theirs',
      setUp: () {
        answer(1, first);
        answer(2, other);
        answerMonth(1);
        answerMonth(2);
      },
      build: build,
      act: (bloc) async {
        bloc.add(const ShowChildIntent(1));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ShowChildIntent(2));
      },
      verify: (bloc) {
        verify(getMonth(childId: 2, month: thisMonth)).called(1);
        expect(bloc.state.childId, 2);
        expect(bloc.state.calendar, calendar);
      },
    );
  });
}
