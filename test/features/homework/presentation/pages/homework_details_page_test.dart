import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_link_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_screen.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_link_navigation.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';
import 'package:al_mahhaba_school/features/homework/presentation/extensions/open_homework.dart';
import 'package:al_mahhaba_school/features/homework/presentation/homework_args.dart';
import 'package:al_mahhaba_school/features/homework/presentation/pages/homework_details_page.dart';
import 'package:al_mahhaba_school/features/homework/presentation/widgets/homework_card.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/test_app.dart';
import '../../homework_fixtures.dart';
import 'homework_page_harness.dart';

void main() {
  late HomeworkPageHarness harness;

  setUpAll(() => provideResultDummy<HomeworkEntity?>());

  setUp(() {
    harness = HomeworkPageHarness()..register();
    when(harness.childrenViewModel.state).thenReturn(
      const ChildrenState(
        children: BaseState.success([omar, lina]),
        selectedId: 1208,
      ),
    );
  });

  tearDown(getIt.reset);

  void found(Result<HomeworkEntity?> result) => when(
    harness.findHomework(any, any, cancel: anyNamed('cancel')),
  ).thenAnswer((_) async => result);

  /// Home, with [open] run from it as a tap would: the homework page goes
  /// over it, as in the app.
  Future<void> pumpFrom(
    WidgetTester tester,
    void Function(BuildContext context) open,
  ) async {
    tester.usePhoneScreen();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => open(context),
              child: const Text('Home'),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.homework,
          builder: (_, _) => const Text('Homework list'),
        ),
        GoRoute(
          path: AppRoutes.homeworkDetails,
          builder: (_, state) => HomeworkDetailsPage(
            homeworkId: int.parse(state.pathParameters['id']!),
            args: state.extra as HomeworkArgs? ?? const HomeworkArgs(),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      TestApp(
        router: router,
        providers: [
          BlocProvider<ChildrenViewModel>.value(
            value: harness.childrenViewModel,
          ),
          BlocProvider<ChatUnreadBloc>.value(value: harness.chatUnreadBloc),
        ],
      ),
    );
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
  }

  testWidgets('tapped on Home: that one alone, nothing loaded, marked seen', (
    tester,
  ) async {
    await pumpFrom(
      tester,
      (context) => context.openHomework(exercise, studentId: omar.studentId),
    );

    expect(find.byType(HomeworkCard), findsOneWidget);
    expect(find.text(exercise.title), findsOneWidget);
    expect(find.text(reading.title), findsNothing);
    verifyZeroInteractions(harness.findHomework);
    verifyZeroInteractions(harness.getHomework);
    // Unread: its chat item is marked read for its child.
    verify(
      harness.markRead([exercise.chatKey!], studentId: omar.studentId),
    ).called(1);
  });

  testWidgets("tapped in the chat: found by its id, for the item's child", (
    tester,
  ) async {
    found(Success(data: reading));

    await pumpFrom(
      tester,
      (context) => context.openChatLink(
        const ChatLinkEntity(
          screen: ChatScreen.homework,
          studentId: 1209,
          itemId: 11,
        ),
      ),
    );

    expect(find.byType(HomeworkCard), findsOneWidget);
    expect(find.text(reading.title), findsOneWidget);
    verify(
      harness.findHomework(1209, 11, cancel: anyNamed('cancel')),
    ).called(1);
    // Read already: nothing to mark.
    verifyNever(harness.markRead(any, studentId: anyNamed('studentId')));
  });

  testWidgets('a chat link naming no homework: the list, as before', (
    tester,
  ) async {
    await pumpFrom(
      tester,
      (context) => context.openChatLink(
        const ChatLinkEntity(screen: ChatScreen.homework, studentId: 1209),
      ),
    );

    expect(find.text('Homework list'), findsOneWidget);
  });

  testWidgets('gone since: says so', (tester) async {
    found(const Success(data: null));

    await pumpFrom(
      tester,
      (context) => context.openChatLink(
        const ChatLinkEntity(screen: ChatScreen.homework, itemId: 999),
        studentId: omar.studentId,
      ),
    );

    expect(find.text(en.homeworkNotFound), findsOneWidget);
    expect(find.byType(HomeworkCard), findsNothing);
  });
}
