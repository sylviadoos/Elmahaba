import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/widgets/app_loading.dart';
import 'package:al_mahhaba_school/core/widgets/load_more_indicator.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_page_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_intent.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_older_failed.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_timeline.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/test_app.dart';
import '../../chat_fixtures.dart';
import '../../chat_mocks.mocks.dart';

/// What the middle of the chat shows in each state, and what the items
/// themselves ask for once they are built.
void main() {
  late MockGetChatUseCase getChat;
  late MockGetCachedChatUseCase getCachedChat;
  late MockSendChatMessageUseCase sendMessage;
  late MockMarkChatReadUseCase markRead;
  late MockDownloadChatAttachmentUseCase downloadAttachment;
  late MockPreviewChatAttachmentUseCase previewAttachment;

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
    when(
      markRead(any, studentId: anyNamed('studentId')),
    ).thenAnswer((_) async => const Success(data: 0));
  });

  ChatBloc build() => ChatBloc(
    getChat,
    getCachedChat,
    sendMessage,
    markRead,
    downloadAttachment,
    previewAttachment,
  );

  /// The timeline on a phone-sized screen, over [bloc].
  Future<void> show(WidgetTester tester, ChatBloc bloc) async {
    tester.usePhoneScreen();
    await tester.pumpWidget(
      TestApp(
        router: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => BlocProvider.value(
                value: bloc,
                child: Scaffold(body: ChatTimeline(scroll: ScrollController())),
              ),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('while it loads: a spinner, nothing else', (tester) async {
    when(
      getChat(studentId: anyNamed('studentId'), cancel: anyNamed('cancel')),
    ).thenAnswer(
      (_) => Future.delayed(const Duration(seconds: 1), () {
        return Success(data: chatPage([]));
      }),
    );
    final bloc = build()
      ..add(const ChildrenChangedIntent([omar], isLoading: false));
    addTearDown(bloc.close);

    await show(tester, bloc);
    await tester.pump();

    expect(find.byType(AppLoading), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('nothing in the chat yet: "No messages yet"', (tester) async {
    when(
      getChat(studentId: anyNamed('studentId'), cancel: anyNamed('cancel')),
    ).thenAnswer((_) async => Success(data: chatPage([])));
    final bloc = build()
      ..add(const ChildrenChangedIntent([omar], isLoading: false));
    addTearDown(bloc.close);

    await show(tester, bloc);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(CenteredStateMessage), findsOneWidget);
    expect(find.text('No messages yet'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('it didn\'t load: why, and "Try again" asks again', (
    tester,
  ) async {
    when(
      getChat(studentId: anyNamed('studentId'), cancel: anyNamed('cancel')),
    ).thenAnswer((_) async => const Failure(exception: NetworkException()));
    final bloc = build()
      ..add(const ChildrenChangedIntent([omar], isLoading: false));
    addTearDown(bloc.close);

    await show(tester, bloc);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(CenteredStateMessage), findsOneWidget);
    final retry = find.text('Try again');
    expect(retry, findsOneWidget);

    when(
      getChat(studentId: anyNamed('studentId'), cancel: anyNamed('cancel')),
    ).thenAnswer((_) async => Success(data: chatPage([omarItem])));
    await tester.tap(retry);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(CenteredStateMessage), findsNothing);
    expect(find.textContaining('signed trip form'), findsOneWidget);
  });

  testWidgets('there are older items: a spinner that asks for them', (
    tester,
  ) async {
    when(
      getChat(studentId: anyNamed('studentId'), cancel: anyNamed('cancel')),
    ).thenAnswer(
      (_) async => Success(
        data: chatPage([omarItem], hasMore: true, nextBefore: 'cursor-1'),
      ),
    );
    // Still on its way, so the spinner is still there to be found.
    final older = Completer<Result<ChatPageEntity>>();
    when(
      getChat(
        studentId: anyNamed('studentId'),
        before: 'cursor-1',
        cancel: anyNamed('cancel'),
      ),
    ).thenAnswer((_) => older.future);
    final bloc = build()
      ..add(const ChildrenChangedIntent([omar], isLoading: false));
    addTearDown(bloc.close);

    await show(tester, bloc);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(LoadMoreIndicator), findsOneWidget);
    // Built as the top comes near: the parent never taps for more.
    verify(
      getChat(
        studentId: omar.studentId,
        before: 'cursor-1',
        cancel: anyNamed('cancel'),
      ),
    ).called(1);

    older.complete(Success(data: chatPage([])));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Nothing older after all: the spinner goes.
    expect(find.byType(LoadMoreIndicator), findsNothing);
  });

  testWidgets('the older ones didn\'t load: a row offering "Try again"', (
    tester,
  ) async {
    when(
      getChat(studentId: anyNamed('studentId'), cancel: anyNamed('cancel')),
    ).thenAnswer(
      (_) async => Success(
        data: chatPage([omarItem], hasMore: true, nextBefore: 'cursor-1'),
      ),
    );
    when(
      getChat(
        studentId: anyNamed('studentId'),
        before: 'cursor-1',
        cancel: anyNamed('cancel'),
      ),
    ).thenAnswer((_) async => const Failure(exception: NetworkException()));
    final bloc = build()
      ..add(const ChildrenChangedIntent([omar], isLoading: false));
    addTearDown(bloc.close);

    await show(tester, bloc);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(ChatOlderFailed), findsOneWidget);
    // What loaded is still on screen.
    expect(find.textContaining('signed trip form'), findsOneWidget);
  });

  testWidgets('only what the parent can see is marked read', (tester) async {
    final many = [
      for (var i = 1; i <= 20; i++) schoolItem('message:$i', about: omar),
    ];
    when(
      getChat(studentId: anyNamed('studentId'), cancel: anyNamed('cancel')),
    ).thenAnswer((_) async => Success(data: chatPage(many, unread: 20)));
    final bloc = build()
      ..add(const ChildrenChangedIntent([omar], isLoading: false));
    addTearDown(bloc.close);

    await show(tester, bloc);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    final marked = verify(
      markRead(captureAny, studentId: anyNamed('studentId')),
    ).captured.expand((keys) => keys as List<String>).toSet();
    // Everything marked read must be where the parent can see it: not a
    // row the list built just off screen, which they never scrolled to.
    final screen =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final seen = <String>{};
    for (final item in many) {
      final row = find.byKey(ValueKey('item:${item.key}'));
      if (row.evaluate().isEmpty) continue;
      final rect = tester.getRect(row);
      if (rect.bottom > 0 && rect.top < screen) seen.add(item.key);
    }

    expect(marked, isNotEmpty);
    expect(marked.difference(seen), isEmpty);
  });
}

final omarItem = schoolItem('message:41', about: omar);
