import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_page_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/new_chat_message_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_effect.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_intent.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_state.dart';

import '../../../../helpers/result_dummy.dart';
import '../../chat_fixtures.dart';
import '../../chat_mocks.mocks.dart';

/// How the chat holds up under what a parent actually does to it: a load
/// that fails and is tried again, leaving before the school answers,
/// refreshing over and over, scrolling up for older items, and the school
/// changing something while the chat is open.
void main() {
  late MockGetChatUseCase getChat;
  late MockGetCachedChatUseCase getCachedChat;
  late MockSendChatMessageUseCase sendMessage;
  late MockMarkChatReadUseCase markRead;
  late MockDownloadChatAttachmentUseCase downloadAttachment;
  late MockPreviewChatAttachmentUseCase previewAttachment;
  late List<ChatEffect> effects;

  setUpAll(() {
    provideResultDummy<ChatPageEntity>();
    provideResultDummy<ChatItemEntity>();
    provideResultDummy<int>();
    provideResultDummy<String>();
  });

  setUp(() {
    getChat = MockGetChatUseCase();
    getCachedChat = MockGetCachedChatUseCase();
    sendMessage = MockSendChatMessageUseCase();
    markRead = MockMarkChatReadUseCase();
    downloadAttachment = MockDownloadChatAttachmentUseCase();
    previewAttachment = MockPreviewChatAttachmentUseCase();
    effects = [];
    when(
      markRead(any, studentId: anyNamed('studentId')),
    ).thenAnswer((_) async => const Success(data: 0));
  });

  ChatBloc build() {
    final bloc = ChatBloc(
      getChat,
      getCachedChat,
      sendMessage,
      markRead,
      downloadAttachment,
      previewAttachment,
    );
    bloc.effects.listen(effects.add);
    return bloc;
  }

  /// A full page (no `limit`, no `before`) of [studentId]'s chat.
  void fullPage(int? studentId, ChatPageEntity page) => when(
    getChat(studentId: studentId, cancel: anyNamed('cancel')),
  ).thenAnswer((_) async => Success(data: page));

  /// A full page of [studentId]'s chat that fails with [exception].
  void fullPageFails(int? studentId, AppException exception) => when(
    getChat(studentId: studentId, cancel: anyNamed('cancel')),
  ).thenAnswer((_) async => Failure(exception: exception));

  /// What a refresh (the latest few) of [studentId]'s chat answers.
  void latestFew(int? studentId, ChatPageEntity page) => when(
    getChat(
      studentId: studentId,
      limit: anyNamed('limit'),
      cancel: anyNamed('cancel'),
    ),
  ).thenAnswer((_) async => Success(data: page));

  final omarItem = schoolItem('message:41', about: omar);
  final linaItem = schoolItem('message:42', about: lina);
  final newest = schoolItem('message:60', about: omar);

  /// The chat open on Omar, loaded and shown.
  Future<void> openOn(ChatBloc bloc, ChatPageEntity page) async {
    fullPage(omar.studentId, page);
    bloc.add(const ChildrenChangedIntent([omar], isLoading: false));
    await Future<void>.delayed(Duration.zero);
  }

  group('it didn\'t load', () {
    blocTest<ChatBloc, ChatState>(
      'nothing kept from before: the error on screen, with "Try again"',
      setUp: () => fullPageFails(omar.studentId, const NetworkException()),
      build: build,
      act: (bloc) =>
          bloc.add(const ChildrenChangedIntent([omar], isLoading: false)),
      verify: (bloc) {
        expect(bloc.state.chat.state, StateType.error);
        expect(bloc.state.chat.exception, isA<NetworkException>());
        expect(bloc.state.page, isNull);
        // Nothing to show in a snack bar: the page itself says so.
        expect(effects, isEmpty);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'the session ended: the error says so, so the page can offer "Log in"',
      setUp: () =>
          fullPageFails(omar.studentId, const UnauthorizedException()),
      build: build,
      act: (bloc) =>
          bloc.add(const ChildrenChangedIntent([omar], isLoading: false)),
      verify: (bloc) =>
          expect(bloc.state.chat.exception, isA<UnauthorizedException>()),
    );

    blocTest<ChatBloc, ChatState>(
      '"Try again": asked again, and it shows',
      setUp: () => fullPageFails(omar.studentId, const NetworkException()),
      build: build,
      act: (bloc) async {
        bloc.add(const ChildrenChangedIntent([omar], isLoading: false));
        await Future<void>.delayed(Duration.zero);
        fullPage(omar.studentId, chatPage([omarItem]));
        bloc.add(const RetryChatIntent());
      },
      verify: (bloc) {
        expect(bloc.state.chat.state, StateType.success);
        expect(bloc.state.page?.items, [omarItem]);
        verify(
          getChat(studentId: omar.studentId, cancel: anyNamed('cancel')),
        ).called(2);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'kept from before: it stays, and a snack bar says why it isn\'t new',
      setUp: () {
        when(getCachedChat(omar.studentId)).thenReturn(chatPage([omarItem]));
        fullPageFails(omar.studentId, const NetworkException());
      },
      build: build,
      act: (bloc) =>
          bloc.add(const ChildrenChangedIntent([omar], isLoading: false)),
      verify: (bloc) {
        expect(bloc.state.chat.state, StateType.success);
        expect(bloc.state.page?.items, [omarItem]);
        expect(effects.single, isA<ShowErrorEffect>());
      },
    );
  });

  group('the parent leaves before the school answers', () {
    test('the request is stopped and nothing is emitted after', () async {
      final cancels = <CancelHandle>[];
      final answer = Completer<Result<ChatPageEntity>>();
      when(getChat(studentId: omar.studentId, cancel: anyNamed('cancel')))
          .thenAnswer((invocation) {
            cancels.add(
              invocation.namedArguments[#cancel] as CancelHandle,
            );
            return answer.future;
          });
      final bloc = build();
      final states = <ChatState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ChildrenChangedIntent([omar], isLoading: false));
      await Future<void>.delayed(Duration.zero);
      final before = states.length;
      await bloc.close();
      answer.complete(const Failure(exception: CancelledException()));
      await Future<void>.delayed(Duration.zero);

      expect(cancels.single.isCancelled, isTrue);
      expect(states.length, before);
    });

    test('items seen just before leaving are still marked read', () async {
      final bloc = build();
      await openOn(bloc, chatPage([omarItem], unread: 1));

      bloc.add(ItemSeenIntent(omarItem.key));
      await Future<void>.delayed(Duration.zero);
      // Before the 400 ms the bloc waits to gather them.
      await bloc.close();
      await Future<void>.delayed(Duration.zero);

      verify(markRead([omarItem.key], studentId: omar.studentId)).called(1);
    });
  });

  group('refreshing again and again', () {
    test('while one is on its way: only one request', () async {
      final answer = Completer<Result<ChatPageEntity>>();
      final bloc = build();
      await openOn(bloc, chatPage([omarItem]));
      when(
        getChat(
          studentId: omar.studentId,
          limit: anyNamed('limit'),
          cancel: anyNamed('cancel'),
        ),
      ).thenAnswer((_) async => answer.future);

      bloc
        ..add(const RefreshChatIntent())
        ..add(const RefreshChatIntent())
        ..add(const RefreshChatIntent());
      await Future<void>.delayed(Duration.zero);

      verify(
        getChat(
          studentId: omar.studentId,
          limit: 5,
          cancel: anyNamed('cancel'),
        ),
      ).called(1);
      answer.complete(Success(data: chatPage([omarItem])));
      await Future<void>.delayed(Duration.zero);
      await bloc.close();
    });

    test('one after another: each asks once more', () async {
      final bloc = build();
      await openOn(bloc, chatPage([omarItem]));
      latestFew(omar.studentId, chatPage([omarItem, newest]));

      bloc.add(const RefreshChatIntent());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const RefreshChatIntent());
      await Future<void>.delayed(Duration.zero);

      verify(
        getChat(
          studentId: omar.studentId,
          limit: 5,
          cancel: anyNamed('cancel'),
        ),
      ).called(2);
      expect(bloc.state.page?.items, [omarItem, newest]);
      await bloc.close();
    });

    test('while older items load: nothing asked, and nothing waits', () async {
      final older = Completer<Result<ChatPageEntity>>();
      final bloc = build();
      await openOn(
        bloc,
        chatPage([omarItem], hasMore: true, nextBefore: 'cursor-1'),
      );
      when(
        getChat(
          studentId: omar.studentId,
          before: 'cursor-1',
          cancel: anyNamed('cancel'),
        ),
      ).thenAnswer((_) async => older.future);
      latestFew(omar.studentId, chatPage([newest]));

      bloc.add(const LoadOlderChatIntent());
      await Future<void>.delayed(Duration.zero);
      // A notification arrives while the older ones are still loading.
      bloc.add(const RefreshChatIntent());
      await Future<void>.delayed(Duration.zero);

      verifyNever(
        getChat(
          studentId: anyNamed('studentId'),
          before: anyNamed('before'),
          limit: 5,
          cancel: anyNamed('cancel'),
        ),
      );
      older.complete(Success(data: chatPage([])));
      await Future<void>.delayed(Duration.zero);
      // The news never arrives: the refresh was dropped, not queued.
      expect(bloc.state.page?.items, [omarItem]);
      await bloc.close();
    });

    test('an item changed at school, older than the latest few', () async {
      final bloc = build();
      final old = schoolItem('message:1', about: omar, isRead: true);
      final items = [
        old,
        for (var i = 2; i <= 7; i++)
          schoolItem('message:$i', about: omar, isRead: true),
      ];
      await openOn(bloc, chatPage(items));
      // The school edited the oldest one; a refresh brings only the last
      // five, which don't include it.
      latestFew(omar.studentId, chatPage(items.sublist(2)));

      bloc.add(const RefreshChatIntent());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.page?.items.first, same(old));
      await bloc.close();
    });
  });

  group('older items', () {
    test('asked for twice while one is on its way: once', () async {
      final answer = Completer<Result<ChatPageEntity>>();
      final bloc = build();
      await openOn(
        bloc,
        chatPage([omarItem], hasMore: true, nextBefore: 'cursor-1'),
      );
      when(
        getChat(
          studentId: omar.studentId,
          before: 'cursor-1',
          cancel: anyNamed('cancel'),
        ),
      ).thenAnswer((_) async => answer.future);

      bloc
        ..add(const LoadOlderChatIntent())
        ..add(const LoadOlderChatIntent());
      await Future<void>.delayed(Duration.zero);

      verify(
        getChat(
          studentId: omar.studentId,
          before: 'cursor-1',
          cancel: anyNamed('cancel'),
        ),
      ).called(1);
      answer.complete(Success(data: chatPage([])));
      await Future<void>.delayed(Duration.zero);
      await bloc.close();
    });

    test('they didn\'t load: what\'s shown stays, "Try again" works', () async {
      final bloc = build();
      await openOn(
        bloc,
        chatPage([omarItem], hasMore: true, nextBefore: 'cursor-1'),
      );
      when(
        getChat(
          studentId: omar.studentId,
          before: 'cursor-1',
          cancel: anyNamed('cancel'),
        ),
      ).thenAnswer((_) async => const Failure(exception: NetworkException()));

      bloc.add(const LoadOlderChatIntent());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.chat.state, StateType.error);
      expect(bloc.state.page?.items, [omarItem]);
      expect(bloc.state.chat.exception, isA<NetworkException>());

      final old = schoolItem('message:1', about: omar);
      when(
        getChat(
          studentId: omar.studentId,
          before: 'cursor-1',
          cancel: anyNamed('cancel'),
        ),
      ).thenAnswer((_) async => Success(data: chatPage([old])));
      bloc.add(const LoadOlderChatIntent());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.chat.state, StateType.success);
      expect(bloc.state.page?.items, [old, omarItem]);
      await bloc.close();
    });

    test('the same item in both pages: shown once', () async {
      final bloc = build();
      await openOn(
        bloc,
        chatPage([omarItem], hasMore: true, nextBefore: 'cursor-1'),
      );
      final old = schoolItem('message:1', about: omar);
      when(
        getChat(
          studentId: omar.studentId,
          before: 'cursor-1',
          cancel: anyNamed('cancel'),
        ),
      ).thenAnswer((_) async => Success(data: chatPage([old, omarItem])));

      bloc.add(const LoadOlderChatIntent());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.page?.items.map((item) => item.key), [
        'message:1',
        'message:41',
      ]);
      await bloc.close();
    });
  });

  group('coming back to a chat', () {
    test('what it last showed first, then a request every time', () async {
      final kept = chatPage([omarItem]);
      when(getCachedChat(omar.studentId)).thenReturn(kept);
      fullPage(omar.studentId, chatPage([omarItem, newest]));
      final bloc = build();
      final states = <ChatState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ChildrenChangedIntent([omar], isLoading: false));
      await Future<void>.delayed(Duration.zero);

      // Shown at once as it was, then as it is now: no spinner between.
      final asked = states.firstWhere((state) => state.isRequested);
      expect(asked.page, same(kept));
      expect(
        states.every((state) => state.chat.state != StateType.loading),
        isTrue,
      );
      expect(bloc.state.page?.items, [omarItem, newest]);
      await bloc.close();
    });

    test('the same chat asked for again adds nothing', () async {
      final bloc = build();
      await openOn(bloc, chatPage([omarItem]));

      // The children load again (the view model emits), same child.
      bloc.add(const ChildrenChangedIntent([omar], isLoading: false));
      await Future<void>.delayed(Duration.zero);

      verify(
        getChat(studentId: omar.studentId, cancel: anyNamed('cancel')),
      ).called(1);
      await bloc.close();
    });
  });

  group('an item about two children', () {
    test('read for one: still marked read for the other', () async {
      final both = ChatItemEntity(
        key: 'message:41',
        sender: omarItem.sender,
        sentAt: omarItem.sentAt,
        children: [...omarItem.children, ...linaItem.children],
        text: omarItem.text,
        isRead: false,
        isEdited: false,
        isDeleted: false,
        canReply: true,
      );
      fullPage(omar.studentId, chatPage([both], unread: 1));
      fullPage(lina.studentId, chatPage([both], unread: 1));
      final bloc = build();

      bloc.add(const ChildrenChangedIntent([omar, lina], isLoading: false));
      await Future<void>.delayed(Duration.zero);
      bloc.add(ItemSeenIntent(both.key));
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Now Lina's chat, where the same item is still new.
      bloc.add(ShowChildChatIntent(lina.studentId));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.studentId, lina.studentId);
      expect(bloc.state.page?.items.single.isRead, isFalse);

      bloc.add(ItemSeenIntent(both.key));
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // It is read on screen for Lina too, not left "new" forever.
      expect(bloc.state.page?.items.single.isRead, isTrue);

      verify(
        markRead([both.key], studentId: omar.studentId),
      ).called(1);
      verify(
        markRead([both.key], studentId: lina.studentId),
      ).called(1);
      await bloc.close();
    });
  });

  group('sending', () {
    test('it failed, then sent again: the same message, not two', () async {
      final bloc = build();
      await openOn(bloc, chatPage([omarItem]));
      final sent = <NewChatMessageEntity>[];
      when(
        sendMessage(
          any,
          cancel: anyNamed('cancel'),
          onProgress: anyNamed('onProgress'),
        ),
      ).thenAnswer((invocation) async {
        sent.add(invocation.positionalArguments.first as NewChatMessageEntity);
        return const Failure(exception: NetworkException());
      });

      bloc.add(const EditDraftIntent('Thank you.'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const SendMessageIntent());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.sendError, isA<NetworkException>());
      // The draft stays, so "Send" can be tapped again.
      expect(bloc.state.draft, 'Thank you.');

      bloc.add(const SendMessageIntent());
      await Future<void>.delayed(Duration.zero);

      expect(sent, hasLength(2));
      expect(sent.first.clientUuid, sent.last.clientUuid);
      await bloc.close();
    });

    test('while it\'s sending, "Send" again does nothing', () async {
      final answer = Completer<Result<ChatItemEntity>>();
      final bloc = build();
      await openOn(bloc, chatPage([omarItem]));
      when(
        sendMessage(
          any,
          cancel: anyNamed('cancel'),
          onProgress: anyNamed('onProgress'),
        ),
      ).thenAnswer((_) => answer.future);

      bloc.add(const EditDraftIntent('Thank you.'));
      await Future<void>.delayed(Duration.zero);
      bloc
        ..add(const SendMessageIntent())
        ..add(const SendMessageIntent());
      await Future<void>.delayed(Duration.zero);

      verify(
        sendMessage(
          any,
          cancel: anyNamed('cancel'),
          onProgress: anyNamed('onProgress'),
        ),
      ).called(1);
      answer.complete(Success(data: sentItem));
      await Future<void>.delayed(Duration.zero);
      await bloc.close();
    });
  });

  group('the school changes something while the chat is open', () {
    test('nothing reaches the chat until it asks again', () async {
      final bloc = build();
      await openOn(bloc, chatPage([omarItem]));
      // The school posts a message; the chat is told nothing.
      latestFew(omar.studentId, chatPage([omarItem, newest]));
      await Future<void>.delayed(const Duration(milliseconds: 600));

      expect(bloc.state.page?.items, [omarItem]);

      // Only a refresh — a push, the app coming back, the page showing
      // again — brings it.
      bloc.add(const RefreshChatIntent());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.page?.items, [omarItem, newest]);
      await bloc.close();
    });
  });
}
