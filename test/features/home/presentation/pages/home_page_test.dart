import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_read_entity.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/month_attendance_entity.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_intent.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/message_counts_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/extensions/dashboard_chat_counts.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/home_bloc.dart';
import 'package:al_mahhaba_school/features/home/presentation/pages/home_page.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/test_app.dart';
import '../../../announcements/announcements_fixtures.dart' show omar;
import '../../../auth/auth_fixtures.dart' show parent;
import '../../../auth/auth_mocks.mocks.dart';
import '../../../chat/chat_mocks.mocks.dart';
import '../../home_fixtures.dart';
import '../../home_mocks.mocks.dart';

final en = lookupAppLocalizations(const Locale('en'));

/// Firebase isn't set up in tests: no pushes come (message notifications
/// turned off).
class _NoPushes implements NotificationService {
  @override
  Stream<Map<String, dynamic>> get onReceived => const Stream.empty();

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

  const noMessages = MessageCountsEntity(messages: 0, notices: 0, total: 0);
  const oneMessage = MessageCountsEntity(messages: 1, notices: 0, total: 1);

  setUpAll(() {
    provideResultDummy<ChildDashboardEntity>();
    provideResultDummy<MonthAttendanceEntity>();
  });

  setUp(() {
    getDashboard = MockGetChildDashboardUseCase();
    reads = StreamController.broadcast();
    addTearDown(reads.close);
    final watchReads = MockWatchChatReadsUseCase();
    when(watchReads()).thenAnswer((_) => reads.stream);
    getIt
      ..registerFactory<HomeBloc>(
        () =>
            HomeBloc(getDashboard, MockGetMonthAttendanceUseCase(), watchReads),
      )
      ..registerSingleton<NotificationService>(_NoPushes());

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

  /// Home on [omar], the school answering each dashboard asked in turn.
  Future<void> pump(
    WidgetTester tester,
    List<ChildDashboardEntity> dashboards,
  ) async {
    tester.usePhoneScreen();
    var call = 0;
    when(getDashboard(any)).thenAnswer(
      (_) async => Success(
        data: dashboards[call < dashboards.length ? call++ : call - 1],
      ),
    );
    final router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
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
    await tester.pump();
  }

  /// Home asks the school again (a read confirmed, standing in for
  /// coming back to Home or pulling it down).
  Future<void> refresh(WidgetTester tester) async {
    reads.add(const ChatReadEntity(unread: 0));
    await tester.pump();
    await tester.pump();
  }

  /// What Home told the badge on Chat, in turn.
  List<int> badgeSet() => [
    for (final intent in verify(
      chatUnreadBloc.add(captureAny),
    ).captured.whereType<SetChatUnreadIntent>())
      intent.count,
  ];

  testWidgets('the badge on Chat says what the School chat card says, and '
      'follows it with no push', (tester) async {
    final before = dashboardWith(messages: noMessages);
    final after = dashboardWith(messages: oneMessage);
    await pump(tester, [before, after]);
    final cardBefore = before.unreadChat.total;
    expect(find.text(en.newCount(cardBefore)), findsOneWidget);
    expect(badgeSet(), [cardBefore]);

    await refresh(tester);

    final cardAfter = after.unreadChat.total;
    expect(cardAfter, cardBefore + 1);
    expect(find.text(en.newCount(cardAfter)), findsOneWidget);
    expect(badgeSet(), [cardAfter]);
    // Set from the dashboard: nothing more asked of the school.
    verifyNever(chatUnreadBloc.add(argThat(isA<LoadChatUnreadIntent>())));
  });
}
