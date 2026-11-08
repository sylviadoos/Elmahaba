import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_items_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_result_entity.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/latest_updates_bloc.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/latest_updates_intent.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/latest_updates_state.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';

import '../../../../helpers/result_dummy.dart';
import '../../home_fixtures.dart';
import '../../home_mocks.mocks.dart';

void main() {
  late MockGetLatestAnnouncementsUseCase getAnnouncements;
  late MockGetLatestHomeworkUseCase getHomework;
  late MockGetLatestResultsUseCase getResults;

  final announcements = latest([holiday, trip], total: 5, unread: 1);
  final homework = latest([mathSheet], unread: 1);
  final results = latest([termResult], total: 7);

  setUpAll(() {
    provideResultDummy<LatestItemsEntity<AnnouncementEntity>>();
    provideResultDummy<LatestItemsEntity<HomeworkEntity>>();
    provideResultDummy<LatestItemsEntity<LatestResultEntity>>();
  });

  setUp(() {
    getAnnouncements = MockGetLatestAnnouncementsUseCase();
    getHomework = MockGetLatestHomeworkUseCase();
    getResults = MockGetLatestResultsUseCase();
    when(
      getAnnouncements(any),
    ).thenAnswer((_) async => Success(data: announcements));
    when(getHomework(any)).thenAnswer((_) async => Success(data: homework));
    when(getResults(any)).thenAnswer((_) async => Success(data: results));
  });

  LatestUpdatesBloc build() =>
      LatestUpdatesBloc(getAnnouncements, getHomework, getResults);

  final loaded = LatestUpdatesState(
    childId: 1208,
    announcements: BaseState.success(announcements),
    homework: BaseState.success(homework),
    results: BaseState.success(results),
  );

  blocTest<LatestUpdatesBloc, LatestUpdatesState>(
    'loads the three for the child, each as it comes',
    build: build,
    act: (bloc) => bloc.add(const ShowChildUpdatesIntent(1208)),
    expect: () => [
      const LatestUpdatesState(
        childId: 1208,
        announcements: BaseState.loading(),
        homework: BaseState.loading(),
        results: BaseState.loading(),
      ),
      isA<LatestUpdatesState>(),
      isA<LatestUpdatesState>(),
      loaded,
    ],
    verify: (_) {
      verify(getAnnouncements(1208)).called(1);
      verify(getHomework(1208)).called(1);
      verify(getResults(1208)).called(1);
    },
  );

  blocTest<LatestUpdatesBloc, LatestUpdatesState>(
    "doesn't load the child shown again",
    build: build,
    seed: () => loaded,
    act: (bloc) => bloc.add(const ShowChildUpdatesIntent(1208)),
    expect: () => <LatestUpdatesState>[],
    verify: (_) {
      verifyNever(getAnnouncements(any));
      verifyNever(getHomework(any));
      verifyNever(getResults(any));
    },
  );

  blocTest<LatestUpdatesBloc, LatestUpdatesState>(
    'shows only the last child picked',
    build: () {
      final first = Completer<Result<LatestItemsEntity<AnnouncementEntity>>>();
      when(getAnnouncements(1208)).thenAnswer((_) => first.future);
      // The first child's comes after the second was picked.
      when(getAnnouncements(1209)).thenAnswer((_) async {
        first.complete(Success(data: latest([trip])));
        return Success(data: latest([holiday]));
      });
      return build();
    },
    act: (bloc) => bloc
      ..add(const ShowChildUpdatesIntent(1208))
      ..add(const ShowChildUpdatesIntent(1209)),
    verify: (bloc) {
      expect(bloc.state.childId, 1209);
      expect(bloc.state.announcements.data, latest([holiday]));
    },
  );

  blocTest<LatestUpdatesBloc, LatestUpdatesState>(
    'shows what came when one fails, and "Try again" loads just that',
    build: () {
      var calls = 0;
      when(getHomework(any)).thenAnswer(
        (_) async => calls++ == 0
            ? Failure(exception: NetworkException())
            : Success(data: homework),
      );
      return build();
    },
    act: (bloc) async {
      bloc.add(const ShowChildUpdatesIntent(1208));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.homework.state, StateType.error);
      expect(bloc.state.announcements.data, announcements);
      expect(bloc.state.results.data, results);
      bloc.add(const RetryUpdatesIntent());
    },
    skip: 4,
    expect: () => [
      loaded.copyWith(homework: const BaseState.loading()),
      loaded,
    ],
    verify: (_) {
      verify(getAnnouncements(1208)).called(1);
      verify(getResults(1208)).called(1);
      verify(getHomework(1208)).called(2);
    },
  );

  blocTest<LatestUpdatesBloc, LatestUpdatesState>(
    'picking the shown child again loads what failed',
    build: build,
    seed: () => loaded.copyWith(results: BaseState.error(NetworkException())),
    act: (bloc) => bloc.add(const ShowChildUpdatesIntent(1208)),
    expect: () => [loaded.copyWith(results: const BaseState.loading()), loaded],
    verify: (_) {
      verifyNever(getAnnouncements(any));
      verifyNever(getHomework(any));
      verify(getResults(1208)).called(1);
    },
  );
}
