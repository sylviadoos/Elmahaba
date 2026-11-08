import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/chat/domain/chat_error_codes.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_link_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_page_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_screen.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/new_chat_message_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_effect.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_intent.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_state.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/picked_attachment.dart';

import '../../../../helpers/result_dummy.dart';
import '../../chat_fixtures.dart';
import '../../chat_mocks.mocks.dart';

void main() {
  late MockGetChatUseCase getChat;
  late MockGetCachedChatUseCase getCachedChat;
  late MockSendChatMessageUseCase sendMessage;
  late MockMarkChatReadUseCase markRead;
  late MockDownloadChatAttachmentUseCase downloadAttachment;
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
    effects = [];
    when(markRead(any)).thenAnswer((_) async => const Success(data: 0));
  });

  ChatBloc build() {
    final bloc = ChatBloc(
      getChat,
      getCachedChat,
      sendMessage,
      markRead,
      downloadAttachment,
    );
    bloc.effects.listen(effects.add);
    return bloc;
  }

  void chatOf(int? studentId, ChatPageEntity page) => when(
    getChat(studentId: studentId, cancel: anyNamed('cancel')),
  ).thenAnswer((_) async => Success(data: page));

  final omarItem = schoolItem('message:41', about: omar);
  final linaItem = schoolItem('message:42', about: lina);

  group('opening', () {
    blocTest<ChatBloc, ChatState>(
      'the children loaded: the first one\'s chat, nothing marked read yet',
      setUp: () => chatOf(omar.studentId, chatPage([omarItem], unread: 1)),
      build: build,
      act: (bloc) =>
          bloc.add(const ChildrenChangedIntent([omar, lina], isLoading: false)),
      verify: (bloc) {
        expect(bloc.state.studentId, omar.studentId);
        expect(bloc.state.page?.items, [omarItem]);
        expect(bloc.state.showsAll, isFalse);
        // Only once it comes on screen.
        verifyNever(markRead(any));
      },
    );

    blocTest<ChatBloc, ChatState>(
      'opened before: at once as it was, no spinner, then as it is now',
      setUp: () {
        when(getCachedChat(omar.studentId)).thenReturn(chatPage([omarItem]));
        chatOf(omar.studentId, chatPage([omarItem, linaItem]));
      },
      build: build,
      act: (bloc) => bloc.add(ShowChildChatIntent(omar.studentId)),
      expect: () => [
        isA<ChatState>()
            .having((s) => s.chat.state, 'state', StateType.success)
            .having((s) => s.page?.items, 'items', [omarItem]),
        isA<ChatState>().having((s) => s.page?.items, 'items', [
          omarItem,
          linaItem,
        ]),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'opened before, and it doesn\'t load now: still shown, why in a snack '
      'bar',
      setUp: () {
        when(getCachedChat(omar.studentId)).thenReturn(chatPage([omarItem]));
        when(
          getChat(studentId: omar.studentId, cancel: anyNamed('cancel')),
        ).thenAnswer((_) async => const Failure(exception: NetworkException()));
      },
      build: build,
      act: (bloc) => bloc.add(ShowChildChatIntent(omar.studentId)),
      verify: (bloc) {
        expect(bloc.state.chat.state, StateType.success);
        expect(bloc.state.page?.items, [omarItem]);
        expect(effects, [isA<ChildPickedEffect>(), isA<ShowErrorEffect>()]);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'the header\'s dots, worked out as it loads',
      setUp: () => chatOf(
        omar.studentId,
        chatPage([
          schoolItem(
            'event:7',
            about: omar,
            link: const ChatLinkEntity(screen: ChatScreen.fees),
          ),
          schoolItem('message:41', about: omar, isRead: true),
        ], unread: 3),
      ),
      build: build,
      act: (bloc) => bloc.add(ShowChildChatIntent(omar.studentId)),
      verify: (bloc) {
        expect(bloc.state.screensWithNews, {ChatScreen.fees});
        // 3 unread in all, 1 of them here.
        expect(bloc.state.othersUnread, isTrue);
      },
    );

    test('closed while it loads: the request is stopped', () async {
      CancelHandle? cancel;
      when(
        getChat(studentId: omar.studentId, cancel: anyNamed('cancel')),
      ).thenAnswer((invocation) {
        cancel = invocation.namedArguments[#cancel] as CancelHandle?;
        return Completer<Result<ChatPageEntity>>().future;
      });
      final bloc = build()..add(ShowChildChatIntent(omar.studentId));
      await Future<void>.delayed(Duration.zero);
      expect(cancel?.isCancelled, isFalse);

      await bloc.close();
      expect(cancel?.isCancelled, isTrue);
    });
  });

  group('marking read', () {
    ChatState loaded() => ChatState(
      isRequested: true,
      chat: BaseState.success(chatPage([omarItem, linaItem], unread: 2)),
    );

    blocTest<ChatBloc, ChatState>(
      'items seen about the same time: one request, then the badge',
      build: build,
      seed: loaded,
      act: (bloc) => bloc
        ..add(const ItemSeenIntent('message:41'))
        ..add(const ItemSeenIntent('message:42'))
        ..add(const ItemSeenIntent('message:41')),
      wait: const Duration(milliseconds: 500),
      verify: (_) {
        verify(markRead(['message:41', 'message:42'])).called(1);
        expect(effects, [
          isA<UnreadChangedEffect>().having((e) => e.count, 'count', 0),
        ]);
      },
    );

    test('seen just before leaving: still marked read', () async {
      final bloc = build()..add(const ItemSeenIntent('message:41'));
      await Future<void>.delayed(Duration.zero);
      await bloc.close();
      verify(markRead(['message:41'])).called(1);
    });
  });

  group('whose chat', () {
    blocTest<ChatBloc, ChatState>(
      'the children still loading: waits for them',
      build: build,
      act: (bloc) =>
          bloc.add(const ChildrenChangedIntent(null, isLoading: true)),
      expect: () => <ChatState>[],
      verify: (_) => verifyNever(
        getChat(
          studentId: anyNamed('studentId'),
          before: anyNamed('before'),
          cancel: anyNamed('cancel'),
        ),
      ),
    );

    blocTest<ChatBloc, ChatState>(
      'the child shown unlinked: the first one left',
      setUp: () {
        chatOf(omar.studentId, chatPage([omarItem]));
        chatOf(lina.studentId, chatPage([linaItem]));
      },
      build: build,
      act: (bloc) async {
        bloc.add(const ChildrenChangedIntent([omar, lina], isLoading: false));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ChildrenChangedIntent([lina], isLoading: false));
      },
      verify: (bloc) {
        expect(bloc.state.studentId, lina.studentId);
        expect(bloc.state.page?.items, [linaItem]);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'another child picked while one loads: only the last one shows',
      build: build,
      act: (bloc) async {
        final slow = Completer<Result<ChatPageEntity>>();
        when(
          getChat(studentId: omar.studentId, cancel: anyNamed('cancel')),
        ).thenAnswer((_) => slow.future);
        chatOf(lina.studentId, chatPage([linaItem]));
        bloc
          ..add(ShowChildChatIntent(omar.studentId))
          ..add(ShowChildChatIntent(lina.studentId));
        await Future<void>.delayed(Duration.zero);
        slow.complete(Success(data: chatPage([omarItem])));
      },
      verify: (bloc) {
        expect(bloc.state.studentId, lina.studentId);
        expect(bloc.state.page?.items, [linaItem]);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'opening: the child every page shows',
      setUp: () => chatOf(lina.studentId, chatPage([linaItem])),
      build: build,
      act: (bloc) => bloc.add(
        ChildrenChangedIntent(
          const [omar, lina],
          isLoading: false,
          selectedId: lina.studentId,
        ),
      ),
      verify: (bloc) => expect(bloc.state.studentId, lina.studentId),
    );

    blocTest<ChatBloc, ChatState>(
      'a child picked here: every page shows them; all of them: no',
      setUp: () {
        chatOf(lina.studentId, chatPage([linaItem]));
        chatOf(null, chatPage([omarItem, linaItem]));
      },
      build: build,
      act: (bloc) async {
        bloc.add(ShowChildChatIntent(lina.studentId));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ShowChildChatIntent(null));
      },
      verify: (_) => expect(effects.whereType<ChildPickedEffect>().map(
        (effect) => effect.studentId,
      ), [lina.studentId]),
    );

    blocTest<ChatBloc, ChatState>(
      'picked on another page: shown here too, not asked again if shown',
      setUp: () {
        chatOf(omar.studentId, chatPage([omarItem]));
        chatOf(lina.studentId, chatPage([linaItem]));
      },
      build: build,
      act: (bloc) async {
        bloc.add(const ChildrenChangedIntent([omar, lina], isLoading: false));
        await Future<void>.delayed(Duration.zero);
        bloc
          ..add(SelectedChildChangedIntent(lina.studentId))
          ..add(SelectedChildChangedIntent(lina.studentId));
      },
      verify: (bloc) {
        expect(bloc.state.studentId, lina.studentId);
        expect(bloc.state.page?.items, [linaItem]);
        verify(
          getChat(studentId: lina.studentId, cancel: anyNamed('cancel')),
        ).called(1);
        // Not a pick here: no need to tell the other pages.
        expect(effects.whereType<ChildPickedEffect>(), isEmpty);
      },
    );
  });

  group('writing, with every child shown', () {
    ChatState shown({
      ChatItemEntity? replyingTo,
      String draft = '',
      List<PickedAttachment> attachments = const [],
    }) => ChatState(
      children: const [omar, lina],
      isRequested: true,
      chat: BaseState.success(chatPage([omarItem, linaItem])),
      replyingTo: replyingTo,
      draft: draft,
      attachments: attachments,
    );

    blocTest<ChatBloc, ChatState>(
      'nothing to send: "Send" is off, and nothing goes',
      build: build,
      seed: shown,
      act: (bloc) => bloc.add(const SendMessageIntent()),
      expect: () => <ChatState>[],
      verify: (bloc) {
        expect(bloc.state.canSendMessage, isFalse);
        verifyNever(
          sendMessage(
            any,
            onProgress: anyNamed('onProgress'),
            cancel: anyNamed('cancel'),
          ),
        );
      },
    );

    test('only files that won\'t go: "Send" is off, even with text', () {
      final state = shown(draft: 'Hello', attachments: [pickedVideo]);
      expect(state.canSendMessage, isFalse);
      expect(shown(attachments: [pickedPdf]).canSendMessage, isTrue);
      expect(
        shown(attachments: [pickedPdf, pickedVideo]).canSendMessage,
        isTrue,
      );
    });

    blocTest<ChatBloc, ChatState>(
      'files alone: only the ones that can go, with their progress',
      setUp: () =>
          when(
            sendMessage(
              any,
              onProgress: anyNamed('onProgress'),
              cancel: anyNamed('cancel'),
            ),
          ).thenAnswer((invocation) async {
            final onProgress =
                invocation.namedArguments[#onProgress]
                    as UploadProgressCallback;
            onProgress(500, 1000);
            onProgress(1000, 1000);
            return Success(data: sentItem);
          }),
      build: build,
      seed: () => shown(attachments: [pickedPdf, pickedVideo]),
      act: (bloc) => bloc.add(const SendMessageIntent()),
      expect: () => contains(
        isA<ChatState>().having((s) => s.upload, 'upload', (
          sent: 500,
          total: 1000,
        )),
      ),
      verify: (bloc) {
        final message =
            verify(
                  sendMessage(
                    captureAny,
                    onProgress: anyNamed('onProgress'),
                    cancel: anyNamed('cancel'),
                  ),
                ).captured.single
                as NewChatMessageEntity;
        expect(message.text, isEmpty);
        expect(message.attachments, [pickedPdf.path]);
        expect(bloc.state.attachments, isEmpty);
        expect(bloc.state.upload, isNull);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'a file the school refused (MSG-18): its row says so, the rest stays',
      setUp: () =>
          when(
            sendMessage(
              any,
              onProgress: anyNamed('onProgress'),
              cancel: anyNamed('cancel'),
            ),
          ).thenAnswer(
            (_) async => Failure(
              exception: ServerException(
                statusCode: 422,
                code: ChatErrorCodes.fileRejected,
                body: {'file_name': pickedPdf.name},
              ),
            ),
          ),
      build: build,
      seed: () => shown(draft: 'The form', attachments: [pickedPdf]),
      act: (bloc) => bloc.add(const SendMessageIntent()),
      verify: (bloc) {
        expect(
          bloc.state.attachments.single.problem,
          AttachmentProblem.rejected,
        );
        expect(bloc.state.draft, 'The form');
        expect(bloc.state.sendError, isNull);
        expect(bloc.state.isSending, isFalse);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'no child picked: a general message, then the box empties',
      setUp: () => when(
        sendMessage(
          any,
          onProgress: anyNamed('onProgress'),
          cancel: anyNamed('cancel'),
        ),
      ).thenAnswer((_) async => Success(data: sentItem)),
      build: build,
      seed: shown,
      act: (bloc) => bloc
        ..add(const EditDraftIntent('  Thank you. '))
        ..add(const SendMessageIntent()),
      verify: (bloc) {
        final message =
            verify(
                  sendMessage(
                    captureAny,
                    onProgress: anyNamed('onProgress'),
                    cancel: anyNamed('cancel'),
                  ),
                ).captured.single
                as NewChatMessageEntity;
        expect(message.studentId, isNull);
        expect(message.text, 'Thank you.');
        expect(bloc.state.draft, isEmpty);
        expect(bloc.state.isSending, isFalse);
        expect(bloc.state.page?.items.last, sentItem);
        expect(effects, [isA<MessageSentEffect>()]);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'Reply on a child\'s item: about that child, the box ready',
      build: build,
      seed: shown,
      act: (bloc) => bloc.add(StartReplyIntent(linaItem)),
      verify: (bloc) {
        expect(bloc.state.replyingTo, linaItem);
        expect(bloc.state.aboutId, lina.studentId);
        expect(effects, [isA<FocusComposerEffect>()]);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'the item stopped taking answers: no Reply on it, a plain message',
      setUp: () =>
          when(
            sendMessage(
              any,
              onProgress: anyNamed('onProgress'),
              cancel: anyNamed('cancel'),
            ),
          ).thenAnswer(
            (_) async => const Failure(
              exception: ServerException(code: ChatErrorCodes.replyNotAllowed),
            ),
          ),
      build: build,
      seed: () => shown(replyingTo: omarItem, draft: 'He was sick.'),
      act: (bloc) => bloc.add(const SendMessageIntent()),
      verify: (bloc) {
        expect(bloc.state.replyingTo, isNull);
        expect(bloc.state.canReplyTo(omarItem), isFalse);
        expect(bloc.state.draft, 'He was sick.');
        expect(effects, [isA<ShowErrorEffect>()]);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'the school closed the chat meanwhile: read-only',
      setUp: () =>
          when(
            sendMessage(
              any,
              onProgress: anyNamed('onProgress'),
              cancel: anyNamed('cancel'),
            ),
          ).thenAnswer(
            (_) async => const Failure(
              exception: ServerException(code: ChatErrorCodes.chatClosed),
            ),
          ),
      build: build,
      seed: () => shown(draft: 'Hello'),
      act: (bloc) => bloc.add(const SendMessageIntent()),
      verify: (bloc) {
        expect(bloc.state.page?.isOpen, isFalse);
        expect(bloc.state.canWrite, isFalse);
        expect(effects, [isA<ShowErrorEffect>()]);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'refused (a file too big…): why, above the box, until it\'s edited',
      setUp: () =>
          when(
            sendMessage(
              any,
              onProgress: anyNamed('onProgress'),
              cancel: anyNamed('cancel'),
            ),
          ).thenAnswer(
            (_) async => const Failure(
              exception: ServerException(
                statusCode: 422,
                fieldErrors: {'attachments.0': 'The file is too big.'},
              ),
            ),
          ),
      build: build,
      seed: () => shown(draft: 'Hello'),
      act: (bloc) async {
        bloc.add(const SendMessageIntent());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.sendError, isA<ServerException>());
        bloc.add(const EditDraftIntent('Hello again'));
      },
      verify: (bloc) {
        expect(bloc.state.sendError, isNull);
        expect(effects, isEmpty);
      },
    );
  });

  group('files', () {
    blocTest<ChatBloc, ChatState>(
      'downloaded: opened',
      setUp: () => when(
        downloadAttachment(attachment, cancel: anyNamed('cancel')),
      ).thenAnswer((_) async => const Success(data: '/tmp/trip-form.pdf')),
      build: build,
      act: (bloc) => bloc.add(const OpenAttachmentIntent(attachment)),
      expect: () => [
        isA<ChatState>().having((s) => s.downloadingId, 'downloading', 77),
        isA<ChatState>().having((s) => s.downloadingId, 'downloading', null),
      ],
      verify: (_) => expect(effects, [
        isA<OpenFileEffect>().having(
          (e) => e.path,
          'path',
          '/tmp/trip-form.pdf',
        ),
      ]),
    );
  });

  group('older items', () {
    final older = schoolItem('message:30', isRead: true);

    blocTest<ChatBloc, ChatState>(
      'come before the ones shown',
      setUp: () => when(
        getChat(
          studentId: omar.studentId,
          before: 'cursor-1',
          cancel: anyNamed('cancel'),
        ),
      ).thenAnswer((_) async => Success(data: chatPage([older]))),
      build: build,
      seed: () => ChatState(
        children: const [omar],
        isRequested: true,
        studentId: omar.studentId,
        chat: BaseState.success(
          chatPage([omarItem], hasMore: true, nextBefore: 'cursor-1'),
        ),
      ),
      act: (bloc) => bloc.add(const LoadOlderChatIntent()),
      verify: (bloc) {
        expect(bloc.state.page?.items, [older, omarItem]);
        expect(bloc.state.page?.hasMore, isFalse);
      },
    );
  });
}
