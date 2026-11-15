import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_read_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_intent.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../home/home_mocks.mocks.dart';
import '../../chat_mocks.mocks.dart';

void main() {
  late MockGetNewMessagesCountUseCase getNewMessagesCount;
  late StreamController<ChatReadEntity> reads;

  setUpAll(() => provideResultDummy<int>());

  setUp(() {
    getNewMessagesCount = MockGetNewMessagesCountUseCase();
    reads = StreamController.broadcast();
    addTearDown(reads.close);
  });

  ChatUnreadBloc build() {
    final watchReads = MockWatchChatReadsUseCase();
    when(watchReads()).thenAnswer((_) => reads.stream);
    return ChatUnreadBloc(getNewMessagesCount, watchReads);
  }

  /// The School chat card's count for the child with [studentId].
  void cardSays(int studentId, int count) => when(
    getNewMessagesCount(studentId),
  ).thenAnswer((_) async => Success(data: count));

  test('starts at none', () => expect(build().state, 0));

  blocTest<ChatUnreadBloc, int>(
    'loaded: what the School chat card says for that child',
    setUp: () => cardSays(146, 3),
    build: build,
    act: (bloc) => bloc.add(const LoadChatUnreadIntent(146)),
    expect: () => [3],
    verify: (_) => verify(getNewMessagesCount(146)).called(1),
  );

  blocTest<ChatUnreadBloc, int>(
    'didn\'t load: the last count stays',
    setUp: () => when(
      getNewMessagesCount(any),
    ).thenAnswer((_) async => const Failure(exception: NetworkException())),
    build: build,
    seed: () => 2,
    act: (bloc) => bloc.add(const LoadChatUnreadIntent(146)),
    expect: () => <int>[],
  );

  blocTest<ChatUnreadBloc, int>(
    'another child picked while asking: only theirs counts',
    setUp: () {
      final late = Completer<Result<int>>();
      when(getNewMessagesCount(146)).thenAnswer((_) => late.future);
      when(getNewMessagesCount(151)).thenAnswer((_) async {
        // The first child's answer comes after.
        Future<void>.delayed(
          Duration.zero,
          () => late.complete(const Success(data: 7)),
        );
        return const Success(data: 1);
      });
    },
    build: build,
    act: (bloc) async {
      bloc
        ..add(const LoadChatUnreadIntent(146))
        ..add(const LoadChatUnreadIntent(151));
      await Future<void>.delayed(const Duration(milliseconds: 10));
    },
    expect: () => [1],
  );

  blocTest<ChatUnreadBloc, int>(
    'Home loaded the card: its count, over one asked for before',
    setUp: () {
      final late = Completer<Result<int>>();
      when(getNewMessagesCount(146)).thenAnswer((_) => late.future);
      Future<void>.delayed(
        const Duration(milliseconds: 5),
        () => late.complete(const Success(data: 9)),
      );
    },
    build: build,
    act: (bloc) async {
      bloc
        ..add(const LoadChatUnreadIntent(146))
        ..add(const SetChatUnreadIntent(2));
      await Future<void>.delayed(const Duration(milliseconds: 10));
    },
    expect: () => [2],
  );

  blocTest<ChatUnreadBloc, int>(
    'forgotten on log out',
    build: build,
    seed: () => 5,
    act: (bloc) => bloc.add(const ClearChatUnreadIntent()),
    expect: () => [0],
  );

  group('a read the school confirmed (even from a page closed meanwhile)', () {
    blocTest<ChatUnreadBloc, int>(
      'asks the card\'s count again: not the read\'s, which has the events',
      setUp: () => cardSays(146, 3),
      build: build,
      act: (bloc) async {
        bloc.add(const LoadChatUnreadIntent(146));
        await Future<void>.delayed(Duration.zero);
        cardSays(146, 1);
        // Homework and results are in the chat's own count.
        reads.add(const ChatReadEntity(studentId: 146, unread: 4));
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [3, 1],
      verify: (_) => verify(getNewMessagesCount(146)).called(2),
    );

    blocTest<ChatUnreadBloc, int>(
      'nothing counted yet: left alone',
      build: build,
      act: (_) async {
        reads.add(const ChatReadEntity(studentId: 146, unread: 1));
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => <int>[],
      verify: (_) => verifyNever(getNewMessagesCount(any)),
    );
  });
}
