import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/app_status/domain/entities/app_status_entity.dart';
import 'package:al_mahhaba_school/features/app_status/presentation/bloc/app_status_bloc.dart';
import 'package:al_mahhaba_school/features/app_status/presentation/bloc/app_status_intent.dart';

import '../../../../helpers/result_dummy.dart';
import '../../app_status_mocks.mocks.dart';

void main() {
  late MockGetAppStatusUseCase getAppStatus;

  setUpAll(() => provideResultDummy<AppStatusEntity>());

  setUp(() => getAppStatus = MockGetAppStatusUseCase());

  AppStatusBloc build() => AppStatusBloc(getAppStatus);

  void answer(bool enabled) => when(
    getAppStatus(),
  ).thenAnswer((_) async => Success(data: AppStatusEntity(enabled: enabled)));

  test('no Log in until the school says', () => expect(build().state, false));

  blocTest<AppStatusBloc, bool>(
    'enabled: Log in shows',
    setUp: () => answer(true),
    build: build,
    act: (bloc) => bloc.add(const LoadAppStatusIntent()),
    expect: () => [true],
  );

  blocTest<AppStatusBloc, bool>(
    'not enabled: Log in hides',
    setUp: () => answer(false),
    build: build,
    seed: () => true,
    act: (bloc) => bloc.add(const LoadAppStatusIntent()),
    expect: () => [false],
  );

  blocTest<AppStatusBloc, bool>(
    'can\'t ask: what was known stays',
    setUp: () => when(
      getAppStatus(),
    ).thenAnswer((_) async => const Failure(exception: NetworkException())),
    build: build,
    act: (bloc) => bloc.add(const LoadAppStatusIntent()),
    expect: () => <bool>[],
  );
}
