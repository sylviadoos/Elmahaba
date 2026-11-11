import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/bloc/complaint_updates_bloc.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/bloc/complaint_updates_intent.dart';

import '../../../../helpers/result_dummy.dart';
import '../../complaints_fixtures.dart';
import '../../complaints_mocks.mocks.dart';

void main() {
  late MockHasNewComplaintUpdatesUseCase hasNewUpdates;
  late MockMarkComplaintsSeenUseCase markSeen;

  final shown = complaintsPage([
    complaint(lastUpdate: DateTime(2026, 11, 8, 17, 30)),
  ]);

  setUpAll(() => provideResultDummy<bool>());

  setUp(() {
    hasNewUpdates = MockHasNewComplaintUpdatesUseCase();
    markSeen = MockMarkComplaintsSeenUseCase();
  });

  ComplaintUpdatesBloc build() => ComplaintUpdatesBloc(hasNewUpdates, markSeen);

  void answerWith(Result<bool> result) =>
      when(hasNewUpdates()).thenAnswer((_) async => result);

  blocTest<ComplaintUpdatesBloc, bool>(
    'the school changed a complaint since the parent looked: the dot shows',
    build: build,
    setUp: () => answerWith(const Success(data: true)),
    act: (bloc) => bloc.add(const LoadComplaintUpdatesIntent()),
    expect: () => [true],
  );

  blocTest<ComplaintUpdatesBloc, bool>(
    'nothing new: no dot',
    build: build,
    setUp: () => answerWith(const Success(data: false)),
    act: (bloc) => bloc.add(const LoadComplaintUpdatesIntent()),
    // Bloc lets the first answer through even when it says the same.
    expect: () => [false],
  );

  blocTest<ComplaintUpdatesBloc, bool>(
    'asking failed: the dot stays as it was',
    build: build,
    seed: () => true,
    setUp: () => answerWith(const Failure(exception: NetworkException())),
    act: (bloc) => bloc.add(const LoadComplaintUpdatesIntent()),
    expect: () => <bool>[],
  );

  blocTest<ComplaintUpdatesBloc, bool>(
    'the complaints are on screen: the dot goes and is remembered',
    build: build,
    seed: () => true,
    act: (bloc) => bloc.add(ComplaintsSeenIntent(shown)),
    expect: () => [false],
    verify: (_) => verify(markSeen(shown)).called(1),
  );

  blocTest<ComplaintUpdatesBloc, bool>(
    'logging out takes the dot off, without touching what was read',
    build: build,
    seed: () => true,
    act: (bloc) => bloc.add(const ClearComplaintUpdatesIntent()),
    expect: () => [false],
    verify: (_) => verifyNever(markSeen(any)),
  );
}
