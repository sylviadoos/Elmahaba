import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/month_attendance_entity.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/use_cases/get_child_dashboard_use_case.dart';
import 'package:al_mahhaba_school/features/home/domain/use_cases/get_new_messages_count_use_case.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/home_bloc.dart';
import 'package:al_mahhaba_school/features/home/presentation/pages/home_page.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/badge_refresher.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/test_app.dart';
import '../../../announcements/announcements_fixtures.dart' show omar;
import '../../../auth/auth_fixtures.dart' show parent;
import '../../../auth/auth_mocks.mocks.dart';
import '../../../chat/chat_mocks.mocks.dart';
import '../../home_fixtures.dart';
import '../../home_mocks.mocks.dart';

/// Pushes the test sends, standing in for the school's notifications.
class _Pushes implements NotificationService {
  final _received = StreamController<Map<String, dynamic>>.broadcast();

  void arrive() => _received.add(const {'type': 'announcement'});

  Future<void> close() => _received.close();

  @override
  Stream<Map<String, dynamic>> get onReceived => _received.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

/// The app as `app.dart` builds it, cut down to the two things that ask
/// the school for a dashboard: `BadgeRefresher` above the router (for the
/// badge on Chat) and `HomePage` under it (for Home itself). Both go
/// through the same `HomeRepo`, so every call it gets is one request the
/// school really receives.
void main() {
  late MockHomeRepo repo;
  late _Pushes pushes;
  late MockParentViewModel parentViewModel;
  late MockChildrenViewModel childrenViewModel;
  late GoRouter router;

  /// Every call the school would get, in order of the child asked about.
  late List<int> asked;

  setUpAll(() {
    provideResultDummy<ChildDashboardEntity>();
    provideResultDummy<MonthAttendanceEntity>();
    provideResultDummy<int>();
  });

  setUp(() {
    asked = [];
    repo = MockHomeRepo();
    when(repo.getChildDashboard(any)).thenAnswer((invocation) async {
      asked.add(invocation.positionalArguments.first as int);
      return Success(data: dashboardWith());
    });

    pushes = _Pushes();
    addTearDown(pushes.close);
    getIt.registerSingleton<NotificationService>(pushes);
    getIt.registerFactory<HomeBloc>(
      () => HomeBloc(
        GetChildDashboardUseCase(repo),
        MockGetMonthAttendanceUseCase(),
        MockWatchChatReadsUseCase(),
      ),
    );
    addTearDown(getIt.reset);

    parentViewModel = MockParentViewModel();
    when(parentViewModel.state).thenReturn(BaseState.success(parent));
    when(parentViewModel.stream).thenAnswer((_) => const Stream.empty());

    childrenViewModel = MockChildrenViewModel();
    when(childrenViewModel.state).thenReturn(
      const ChildrenState(
        children: BaseState.success([omar]),
        selectedId: 1208,
      ),
    );
    when(childrenViewModel.stream).thenAnswer((_) => const Stream.empty());
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.usePhoneScreen();
    router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
        GoRoute(
          path: AppRoutes.settings,
          builder: (_, _) => const Scaffold(body: Text('Settings')),
        ),
        GoRoute(
          path: AppRoutes.chat,
          builder: (_, _) => const Scaffold(body: Text('Chat')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ParentViewModel>.value(value: parentViewModel),
          BlocProvider<ChildrenViewModel>.value(value: childrenViewModel),
          BlocProvider(
            create: (_) => ChatUnreadBloc(
              GetNewMessagesCountUseCase(repo),
              MockWatchChatReadsUseCase(),
            ),
          ),
        ],
        // Above the router, exactly as in `app.dart`; it is handed the
        // router because `GoRouter.of` cannot reach up here.
        child: BadgeRefresher(
          router: router,
          child: TestApp(router: router),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('opening Home asks once: only Home asks, the badge is told '
      'the count from the answer', (tester) async {
    await pumpApp(tester);

    expect(asked, [omar.studentId]);
  });

  testWidgets('a notification while Home is shown: the school is asked '
      'once — Home asks, and the badge takes the count from its answer', (
    tester,
  ) async {
    await pumpApp(tester);
    asked.clear();

    pushes.arrive();
    await tester.pumpAndSettle();

    expect(asked, [omar.studentId]);
  });

  testWidgets('coming back to the app: once, for the same reason', (
    tester,
  ) async {
    await pumpApp(tester);
    asked.clear();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(asked, [omar.studentId]);
  });

  testWidgets('a notification while another page covers Home: still asked '
      'once, by the badge — the skip must not reach this far', (tester) async {
    await pumpApp(tester);
    router.push(AppRoutes.settings);
    await tester.pumpAndSettle();
    asked.clear();

    pushes.arrive();
    await tester.pumpAndSettle();

    // The trap this guards: the router's own location still reads /home
    // while a page is pushed over it. Had the skip gone by that, the badge
    // would have stayed quiet here too — and with Home quiet underneath,
    // nobody would be keeping the count right.
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      AppRoutes.home,
      reason: 'the location lies: Settings is what the parent sees',
    );
    expect(asked, [omar.studentId]);
  });

  testWidgets('the badge keeps counting while the chat itself is open', (
    tester,
  ) async {
    await pumpApp(tester);
    router.push(AppRoutes.chat);
    await tester.pumpAndSettle();
    asked.clear();

    pushes.arrive();
    await tester.pumpAndSettle();

    // The moment a chat badge matters most.
    expect(asked, [omar.studentId]);
  });
}
