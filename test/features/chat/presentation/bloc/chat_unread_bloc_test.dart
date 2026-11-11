import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_intent.dart';

import '../../../../helpers/result_dummy.dart';
import '../../chat_mocks.mocks.dart';

void main() {
  late MockGetChatUnreadCountUseCase getUnreadCount;
  late StreamController<int> reads;

  setUpAll(() => provideResultDummy<int>());

  setUp(() {
    getUnreadCount = MockGetChatUnreadCountUseCase();
    reads = StreamController.broadcast();
    addTearDown(reads.close);
  });

  ChatUnreadBloc build() {
    final watchReads = MockWatchChatReadsUseCase();
    when(watchReads()).thenAnswer((_) => reads.stream);
    return ChatUnreadBloc(getUnreadCount, watchReads);
  }

  test('starts at none', () => expect(build().state, 0));

  blocTest<ChatUnreadBloc, int>(
    'loaded: the count',
    setUp: () =>
        when(getUnreadCount()).thenAnswer((_) async => const Success(data: 3)),
    build: build,
    act: (bloc) => bloc.add(const LoadChatUnreadIntent()),
    expect: () => [3],
  );

  blocTest<ChatUnreadBloc, int>(
    'didn\'t load: the last count stays',
    setUp: () => when(
      getUnreadCount(),
    ).thenAnswer((_) async => const Failure(exception: NetworkException())),
    build: build,
    seed: () => 2,
    act: (bloc) => bloc.add(const LoadChatUnreadIntent()),
    expect: () => <int>[],
  );

  blocTest<ChatUnreadBloc, int>(
    'what the chat learned, then forgotten on log out',
    build: build,
    act: (bloc) => bloc
      ..add(const SetChatUnreadIntent(5))
      ..add(const ClearChatUnreadIntent()),
    expect: () => [5, 0],
  );

  blocTest<ChatUnreadBloc, int>(
    'a read the school confirmed, even from a page closed meanwhile',
    build: build,
    seed: () => 3,
    act: (_) => reads.add(1),
    expect: () => [1],
  );
}
