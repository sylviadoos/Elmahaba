import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';
import 'package:al_mahhaba_school/core/widgets/page_refresher.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_state.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/notification_router.dart';

import '../../../auth/auth_fixtures.dart';
import '../../../auth/auth_mocks.mocks.dart';

/// Firebase isn't set up in tests: a notification is tapped by calling
/// [tap]. The real stream takes one listener and holds what arrives before
/// it, as a tap that opened the app does.
class _Taps implements NotificationService {
  final _taps = StreamController<Map<String, dynamic>>();

  void tap([Map<String, dynamic> data = const {'type': 'message'}]) =>
      _taps.add(data);

  Future<void> close() => _taps.close();

  @override
  Stream<Map<String, dynamic>> get onTap => _taps.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  late _Taps notifications;
  late MockParentViewModel parentViewModel;
  late StreamController<ParentState> parentStates;
  late GoRouter router;

  /// A page under each route the tests open, named by its path.
  GoRoute page(String path) =>
      GoRoute(path: path, builder: (_, _) => Text('at $path'));

  setUp(() {
    notifications = _Taps();
    parentViewModel = MockParentViewModel();
    parentStates = StreamController.broadcast();
    when(parentViewModel.stream).thenAnswer((_) => parentStates.stream);
    getIt.registerSingleton<NotificationService>(notifications);
    addTearDown(getIt.reset);
    addTearDown(notifications.close);
    addTearDown(parentStates.close);
  });

  /// The app around the router, opening on [at] — the splash by default,
  /// as the app itself starts.
  Future<void> pumpApp(
    WidgetTester tester, {
    required bool signedIn,
    String at = AppRoutes.splash,
  }) async {
    when(parentViewModel.state).thenReturn(
      signedIn ? BaseState.success(parent) : const BaseState.initial(),
    );
    router = GoRouter(
      initialLocation: at,
      routes: [
        page(AppRoutes.splash),
        page(AppRoutes.home),
        page(AppRoutes.chat),
        page(AppRoutes.fees),
        page(AppRoutes.complaints),
        page(AppRoutes.complaintDetails),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<ParentViewModel>.value(
        value: parentViewModel,
        child: NotificationRouter(
          router: router,
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );
  }

  /// The page the parent is looking at.
  String shown() => shownRoutePath(router.routerDelegate);

  /// The tap is listened for, opened after the frame it came in.
  Future<void> settle(WidgetTester tester) => tester.pumpAndSettle();

  testWidgets('a message from the school opens the chat', (tester) async {
    await pumpApp(tester, signedIn: true, at: AppRoutes.home);

    notifications.tap();
    await settle(tester);

    expect(shown(), AppRoutes.chat);
  });

  testWidgets('the screen the push names opens instead', (tester) async {
    await pumpApp(tester, signedIn: true, at: AppRoutes.home);

    notifications.tap(const {'screen': 'fees'});
    await settle(tester);

    expect(shown(), AppRoutes.fees);
  });

  testWidgets('a reply to a complaint opens that complaint', (tester) async {
    await pumpApp(tester, signedIn: true, at: AppRoutes.home);

    notifications.tap(const {'screen': 'complaints', 'item_id': '5521'});
    await settle(tester);

    expect(shown(), AppRoutes.complaintDetailsOf(5521));
  });

  testWidgets('the chat is already open: it is not opened over itself', (
    tester,
  ) async {
    await pumpApp(tester, signedIn: true, at: AppRoutes.chat);

    notifications.tap();
    await settle(tester);

    expect(shown(), AppRoutes.chat);
    // The one page, not a second copy of it over the first.
    expect(router.routerDelegate.currentConfiguration.matches.length, 1);
  });

  testWidgets('tapped while the app was closed: it waits for the splash', (
    tester,
  ) async {
    await pumpApp(tester, signedIn: true);

    // The push that opened the app, while the splash still counts down.
    notifications.tap();
    await settle(tester);
    expect(shown(), AppRoutes.splash, reason: 'the splash is still showing');

    // The splash is done with the session and opens Home.
    router.go(AppRoutes.home);
    await settle(tester);

    expect(shown(), AppRoutes.chat, reason: 'opened over Home, not lost');
  });

  testWidgets('no parent signed in yet: it waits for them', (tester) async {
    await pumpApp(tester, signedIn: false, at: AppRoutes.home);

    notifications.tap();
    await settle(tester);
    expect(shown(), AppRoutes.home, reason: 'nothing to open the chat on');

    // The session was saved after all: the parent is signed in.
    final signedIn = BaseState.success(parent);
    when(parentViewModel.state).thenReturn(signedIn);
    parentStates.add(signedIn);
    await settle(tester);

    expect(shown(), AppRoutes.chat);
  });

  testWidgets('nothing tapped: nothing is opened', (tester) async {
    await pumpApp(tester, signedIn: true, at: AppRoutes.home);

    await settle(tester);

    expect(shown(), AppRoutes.home);
  });
}
