import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/app_version/domain/entities/app_version_entity.dart';
import 'package:al_mahhaba_school/features/app_version/presentation/bloc/app_version_bloc.dart';
import 'package:al_mahhaba_school/features/app_version/presentation/bloc/app_version_intent.dart';
import 'package:al_mahhaba_school/features/app_version/presentation/bloc/app_version_state.dart';

import '../../../../helpers/result_dummy.dart';
import '../../app_version_fixtures.dart';
import '../../app_version_mocks.mocks.dart';

void main() {
  late MockCheckAppVersionUseCase checkAppVersion;
  late MockGetSavedForcedUpdateUseCase getSavedForcedUpdate;

  setUpAll(() => provideResultDummy<AppVersionEntity>());

  setUp(() {
    checkAppVersion = MockCheckAppVersionUseCase();
    getSavedForcedUpdate = MockGetSavedForcedUpdateUseCase();
    when(getSavedForcedUpdate()).thenAnswer((_) async => null);
  });

  AppVersionBloc build() =>
      AppVersionBloc(checkAppVersion, getSavedForcedUpdate);

  void schoolSays(AppVersionEntity update) =>
      when(checkAppVersion()).thenAnswer((_) async => Success(data: update));

  void schoolFails() => when(
    checkAppVersion(),
  ).thenAnswer((_) async => const Failure(exception: NetworkException()));

  test(
    'starts with nothing',
    () => expect(build().state, const NoUpdateState()),
  );

  blocTest<AppVersionBloc, AppVersionState>(
    'up to date: nothing',
    setUp: () => schoolSays(upToDate),
    build: build,
    act: (bloc) => bloc.add(const CheckAppVersionIntent()),
    expect: () => <AppVersionState>[],
  );

  blocTest<AppVersionBloc, AppVersionState>(
    'optional: Update or Later',
    setUp: () => schoolSays(optional),
    build: build,
    act: (bloc) => bloc.add(const CheckAppVersionIntent()),
    expect: () => [const OptionalUpdateState(optional)],
  );

  blocTest<AppVersionBloc, AppVersionState>(
    'forced: Update only',
    setUp: () => schoolSays(forced),
    build: build,
    act: (bloc) => bloc.add(const CheckAppVersionIntent()),
    expect: () => [const ForcedUpdateState(forced)],
  );

  blocTest<AppVersionBloc, AppVersionState>(
    'kept from before: shown at once, and still when the school is out of '
    'reach',
    setUp: () {
      when(getSavedForcedUpdate()).thenAnswer((_) async => forced);
      schoolFails();
    },
    build: build,
    act: (bloc) => bloc.add(const CheckAppVersionIntent()),
    expect: () => [const ForcedUpdateState(forced)],
    verify: (bloc) => expect(bloc.state, const ForcedUpdateState(forced)),
  );

  blocTest<AppVersionBloc, AppVersionState>(
    'forced, then the school out of reach: it stays',
    setUp: () => schoolSays(forced),
    build: build,
    act: (bloc) async {
      bloc.add(const CheckAppVersionIntent());
      await Future<void>.delayed(Duration.zero);
      schoolFails();
      bloc.add(const CheckAppVersionIntent());
    },
    expect: () => [const ForcedUpdateState(forced)],
    verify: (bloc) => expect(bloc.state, const ForcedUpdateState(forced)),
  );

  blocTest<AppVersionBloc, AppVersionState>(
    "forced, then the school lifts it: the app's back",
    setUp: () => when(getSavedForcedUpdate()).thenAnswer((_) async => forced),
    build: build,
    act: (bloc) {
      schoolSays(upToDate);
      bloc.add(const CheckAppVersionIntent());
    },
    expect: () => [const ForcedUpdateState(forced), const NoUpdateState()],
  );

  blocTest<AppVersionBloc, AppVersionState>(
    'Later on a forced update: nothing',
    setUp: () => schoolSays(forced),
    build: build,
    act: (bloc) async {
      bloc.add(const CheckAppVersionIntent());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const PostponeUpdateIntent());
    },
    expect: () => [const ForcedUpdateState(forced)],
  );

  blocTest<AppVersionBloc, AppVersionState>(
    'Later on an optional one: gone, and not again while the app is open',
    setUp: () => schoolSays(optional),
    build: build,
    act: (bloc) async {
      bloc.add(const CheckAppVersionIntent());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const PostponeUpdateIntent());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const CheckAppVersionIntent());
    },
    expect: () => [const OptionalUpdateState(optional), const NoUpdateState()],
  );

  blocTest<AppVersionBloc, AppVersionState>(
    'Later, then it becomes forced: forced all the same',
    setUp: () => schoolSays(optional),
    build: build,
    act: (bloc) async {
      bloc.add(const CheckAppVersionIntent());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const PostponeUpdateIntent());
      await Future<void>.delayed(Duration.zero);
      schoolSays(forced);
      bloc.add(const CheckAppVersionIntent());
    },
    expect: () => [
      const OptionalUpdateState(optional),
      const NoUpdateState(),
      const ForcedUpdateState(forced),
    ],
  );
}
