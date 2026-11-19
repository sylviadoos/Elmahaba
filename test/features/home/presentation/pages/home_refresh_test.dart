import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/month_attendance_entity.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_read_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/dashboard_attendance_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/message_counts_entity.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/home_bloc.dart';
import 'package:al_mahhaba_school/features/home/presentation/pages/home_page.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/home_dashboard_skeleton.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/test_app.dart';
import '../../../announcements/announcements_fixtures.dart' show omar;
import '../../../auth/auth_fixtures.dart' show parent;
import '../../../auth/auth_mocks.mocks.dart';
import '../../../chat/chat_mocks.mocks.dart';
import '../../home_fixtures.dart';
import '../../home_mocks.mocks.dart';

final en = lookupAppLocalizations(const Locale('en'));

/// Pushes the test can send, standing in for the school's notifications.
class _Pushes implements NotificationService {
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  void send() => _controller.add(const {'type': 'announcement'});

  Future<void> close() => _controller.close();

  @override
  Stream<Map<String, dynamic>> get onReceived => _controller.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  late MockGetChildDashboardUseCase getDashboard;
  late StreamController<ChatReadEntity> reads;
  late MockChildrenViewModel childrenViewModel;
  late MockParentViewModel parentViewModel;
  late MockChatUnreadBloc chatUnreadBloc;
  late _Pushes pushes;
  late int calls;

  final dashboard = dashboardWith();
  final changed = dashboardWith(presentDays: 9);

  /// Nothing happened at school yet.
  const nothingYet = ChildDashboardEntity(
    attendance: DashboardAttendanceEntity(),
    messages: MessageCountsEntity(messages: 0, notices: 0, total: 0),
  );

  setUpAll(() {
    provideResultDummy<ChildDashboardEntity>();
    provideResultDummy<MonthAttendanceEntity>();
  });

  setUp(() {
    calls = 0;
    getDashboard = MockGetChildDashboardUseCase();
    reads = StreamController.broadcast();
    addTearDown(reads.close);
    pushes = _Pushes();
    addTearDown(pushes.close);
    final watchReads = MockWatchChatReadsUseCase();
    when(watchReads()).thenAnswer((_) => reads.stream);
    getIt
      ..registerFactory<HomeBloc>(
        () =>
            HomeBloc(getDashboard, MockGetMonthAttendanceUseCase(), watchReads),
      )
      ..registerSingleton<NotificationService>(pushes);

    childrenViewModel = MockChildrenViewModel();
    when(childrenViewModel.state).thenReturn(
      const ChildrenState(
        children: BaseState.success([omar]),
        selectedId: 1208,
      ),
    );
    when(childrenViewModel.stream).thenAnswer((_) => const Stream.empty());
    parentViewModel = MockParentViewModel();
    when(parentViewModel.state).thenReturn(BaseState.success(parent));
    when(parentViewModel.stream).thenAnswer((_) => const Stream.empty());
    chatUnreadBloc = MockChatUnreadBloc();
    when(chatUnreadBloc.stream).thenAnswer((_) => const Stream.empty());
  });
  tearDown(getIt.reset);

  /// The school answers each dashboard asked for in turn, counting them.
  void answers(List<Result<ChildDashboardEntity>> results) {
    when(getDashboard(any)).thenAnswer((_) async {
      final result =
          results[calls < results.length ? calls : results.length - 1];
      calls++;
      return result;
    });
  }

  late GoRouter router;

  /// Home, with a page it can open over itself (Settings).
  Future<void> pump(WidgetTester tester) async {
    tester.usePhoneScreen();
    router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
        GoRoute(
          path: AppRoutes.settings,
          builder: (_, _) => const Scaffold(body: Text('Settings')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      TestApp(
        router: router,
        providers: [
          BlocProvider<ChildrenViewModel>.value(value: childrenViewModel),
          BlocProvider<ParentViewModel>.value(value: parentViewModel),
          BlocProvider<ChatUnreadBloc>.value(value: chatUnreadBloc),
        ],
      ),
    );
    await tester.pump();
  }

  /// Pulls Home down, as a parent does to refresh it.
  Future<void> pullDown(WidgetTester tester) async {
    await tester.fling(
      find.byType(RefreshIndicator),
      const Offset(0, 320),
      1000,
    );
    await tester.pump();
  }

  group('opening Home', () {
    testWidgets('the skeleton while the school answers, then the child\'s '
        'dashboard, asked for once', (tester) async {
      final pending = Completer<Result<ChildDashboardEntity>>();
      when(getDashboard(any)).thenAnswer((_) {
        calls++;
        return pending.future;
      });
      await pump(tester);

      expect(find.byType(HomeDashboardSkeleton), findsOneWidget);

      pending.complete(Success(data: dashboard));
      await tester.pump();
      await tester.pump();

      expect(find.byType(HomeDashboardSkeleton), findsNothing);
      expect(find.text('${dashboard.attendance.presentDays}'), findsOneWidget);
      expect(calls, 1);
      verify(getDashboard(omar.studentId)).called(1);
    });

    testWidgets('a child with nothing yet: the empty cards, not an error', (
      tester,
    ) async {
      answers([const Success(data: nothingYet)]);
      await pump(tester);
      await tester.pump();

      expect(find.text(en.noAnnouncements), findsOneWidget);
      expect(find.text(en.noHomework), findsOneWidget);
      expect(find.text(en.noResultsYet), findsWidgets);
      expect(find.text(en.tryAgain), findsNothing);
    });
  });

  group('when it couldn\'t load', () {
    testWidgets('no internet: the message and "Try again", which loads it', (
      tester,
    ) async {
      answers([
        const Failure(exception: NetworkException()),
        Success(data: dashboard),
      ]);
      await pump(tester);
      await tester.pump();

      expect(find.byType(StateMessage), findsOneWidget);
      expect(find.text(en.noInternet), findsOneWidget);
      expect(find.text(en.tryAgain), findsOneWidget);
      expect(calls, 1);

      await tester.tap(find.text(en.tryAgain));
      await tester.pump();
      await tester.pump();

      expect(calls, 2);
      expect(find.byType(StateMessage), findsNothing);
      expect(find.text('${dashboard.attendance.presentDays}'), findsOneWidget);
    });

    testWidgets('in the middle of the room under the header, not up '
        'against it', (tester) async {
      answers([const Failure(exception: NetworkException())]);
      await pump(tester);
      await tester.pump();

      final screen = tester.getRect(find.byType(Scaffold).first);
      final message = tester.getRect(find.byType(StateMessage));
      final fromTop = (message.center.dy - screen.top) / screen.height;

      // It stands for the whole page, so it sits in the middle of it.
      // Up against the header — what this guards against — it would be
      // about 0.38 of the way down instead.
      expect(fromTop, closeTo(0.53, 0.05));
    });

    testWidgets('the server broke: its own message, with "Try again"', (
      tester,
    ) async {
      answers([
        const Failure(
          exception: ServerException(statusCode: 500, message: 'Server error'),
        ),
      ]);
      await pump(tester);
      await tester.pump();

      expect(find.text('Server error'), findsOneWidget);
      expect(find.text(en.tryAgain), findsOneWidget);
    });

    testWidgets('the session ended: "Log out" instead of "Try again"', (
      tester,
    ) async {
      answers([const Failure(exception: UnauthorizedException())]);
      await pump(tester);
      await tester.pump();

      expect(find.text(en.logout), findsOneWidget);
      expect(find.text(en.tryAgain), findsNothing);
    });
  });

  group('asking the school again', () {
    testWidgets('pulled down: asked again, what\'s shown stays meanwhile, '
        'and the spinner stops', (tester) async {
      answers([Success(data: dashboard), Success(data: changed)]);
      await pump(tester);
      await tester.pump();
      expect(calls, 1);

      await pullDown(tester);

      // The old numbers are still there while the new ones are on the way.
      expect(find.text('${dashboard.attendance.presentDays}'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(calls, 2);
      expect(find.text('${changed.attendance.presentDays}'), findsOneWidget);
      expect(find.byType(RefreshProgressIndicator), findsNothing);
    });

    testWidgets('back on Home from a page opened over it: asked again', (
      tester,
    ) async {
      answers([Success(data: dashboard), Success(data: changed)]);
      await pump(tester);
      await tester.pump();
      expect(calls, 1);

      router.push(AppRoutes.settings);
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      expect(calls, 1, reason: 'nothing is asked while Home is underneath');

      router.pop();
      await tester.pumpAndSettle();

      expect(calls, 2);
      expect(find.text('${changed.attendance.presentDays}'), findsOneWidget);
    });

    testWidgets('a notification while Home is shown: asked again', (
      tester,
    ) async {
      answers([Success(data: dashboard), Success(data: changed)]);
      await pump(tester);
      await tester.pump();

      pushes.send();
      await tester.pumpAndSettle();

      expect(calls, 2);
      expect(find.text('${changed.attendance.presentDays}'), findsOneWidget);
    });

    testWidgets('a notification while another page is over Home: it waits '
        'for Home to show again, and asks once', (tester) async {
      answers([Success(data: dashboard), Success(data: changed)]);
      await pump(tester);
      await tester.pump();

      router.push(AppRoutes.settings);
      await tester.pumpAndSettle();
      pushes.send();
      await tester.pumpAndSettle();
      expect(calls, 1);

      router.pop();
      await tester.pumpAndSettle();

      expect(calls, 2);
    });

    testWidgets('a refresh that fails: what\'s shown stays, with no error '
        'in its place', (tester) async {
      answers([
        Success(data: dashboard),
        const Failure(exception: NetworkException()),
      ]);
      await pump(tester);
      await tester.pump();

      await pullDown(tester);
      await tester.pumpAndSettle();

      expect(calls, 2);
      expect(find.byType(StateMessage), findsNothing);
      expect(find.text('${dashboard.attendance.presentDays}'), findsOneWidget);
    });
  });

  testWidgets('left before the school answered: no error, and nothing asked '
      'for the page that is gone', (tester) async {
    final pending = Completer<Result<ChildDashboardEntity>>();
    when(getDashboard(any)).thenAnswer((_) {
      calls++;
      return pending.future;
    });
    await pump(tester);
    expect(calls, 1);

    // Home is replaced: its bloc is closed with the request still out.
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete(Success(data: dashboard));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  group('with no children', () {
    setUp(() {
      when(
        childrenViewModel.state,
      ).thenReturn(const ChildrenState(children: BaseState.success([])));
    });

    testWidgets('"No children yet" is shown and nothing is asked of the '
        'school', (tester) async {
      await pump(tester);
      await tester.pump();

      expect(find.text(en.noChildrenYet), findsOneWidget);
      expect(calls, 0);
    });

    testWidgets('pulling down stops rather than spinning for good: there is '
        'no child to ask about, so nothing is waited on', (tester) async {
      await pump(tester);
      await tester.pump();

      await pullDown(tester);
      await tester.pumpAndSettle();

      expect(calls, 0);
      expect(find.byType(RefreshProgressIndicator), findsNothing);
      expect(find.text(en.noChildrenYet), findsOneWidget);
    });
  });
}
