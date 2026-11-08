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

  setUpAll(() => provideResultDummy<int>());

  setUp(() => getUnreadCount = MockGetChatUnreadCountUseCase());

  ChatUnreadBloc build() => ChatUnreadBloc(getUnreadCount);

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
}
