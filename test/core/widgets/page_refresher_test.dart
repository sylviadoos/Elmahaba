import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';
import 'package:al_mahhaba_school/core/widgets/page_refresher.dart';

/// Pushes that arrive while the app is open, sent by the test.
class _Pushes implements NotificationService {
  final received = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get onReceived => received.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Pushes pushes;
  late int refreshes;
  late GoRouter router;

  setUp(() {
    pushes = _Pushes();
    refreshes = 0;
    getIt.registerSingleton<NotificationService>(pushes);
  });

  tearDown(() async {
    await pushes.received.close();
    await getIt.reset();
  });

  /// The page at `/page`, with `/other` to open over it.
  Future<void> pump(WidgetTester tester) async {
    router = GoRouter(
      initialLocation: '/page',
      routes: [
        GoRoute(
          path: '/page',
          builder: (_, _) => PageRefresher(
            path: '/page',
            onRefresh: () => refreshes++,
            child: const Text('page'),
          ),
        ),
        GoRoute(path: '/other', builder: (_, _) => const Text('other')),
        // A piece of the page itself, opened over it: a photo from the
        // chat, a certificate from the results.
        GoRoute(path: '/page/photo', builder: (_, _) => const Text('photo')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  }

  testWidgets('a notification while shown: asks again', (tester) async {
    await pump(tester);
    expect(refreshes, 0);

    pushes.received.add({'type': 'excuse'});
    await tester.pump(PageRefresher.notificationDelay);
    await tester.pump();

    expect(refreshes, 1);
  });

  testWidgets('back to it: asks again, once', (tester) async {
    await pump(tester);

    unawaited(router.push('/other'));
    await tester.pumpAndSettle();
    expect(refreshes, 0);

    router.pop();
    await tester.pumpAndSettle();
    expect(refreshes, 1);
  });

  testWidgets('a piece of the page over it: nothing to ask on the way '
      'back, and a notification still reaches it', (tester) async {
    await pump(tester);

    unawaited(router.push('/page/photo'));
    await tester.pumpAndSettle();
    // Still looking at this page, so the push is for it.
    pushes.received.add({'type': 'chat'});
    await tester.pump(PageRefresher.notificationDelay);
    await tester.pump();
    expect(refreshes, 1);

    router.pop();
    await tester.pumpAndSettle();
    // Closing the photo changed nothing at school: nothing asked again.
    expect(refreshes, 1);
  });

  testWidgets('a notification while hidden waits for it to show', (
    tester,
  ) async {
    await pump(tester);
    unawaited(router.push('/other'));
    await tester.pumpAndSettle();

    pushes.received.add({'type': 'excuse'});
    await tester.pump(PageRefresher.notificationDelay);
    await tester.pump();
    expect(refreshes, 0);

    router.pop();
    await tester.pumpAndSettle();
    expect(refreshes, 1);
  });

  testWidgets('a tab: back from another tab, or a page over the tabs', (
    tester,
  ) async {
    late StatefulNavigationShell shell;
    router = GoRouter(
      initialLocation: '/page',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, _, navigationShell) => shell = navigationShell,
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/page',
                  builder: (_, _) => PageRefresher(
                    path: '/page',
                    onRefresh: () => refreshes++,
                    child: const Text('page'),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/tab', builder: (_, _) => const Text('tab')),
              ],
            ),
          ],
        ),
        GoRoute(path: '/other', builder: (_, _) => const Text('other')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    shell.goBranch(1);
    await tester.pumpAndSettle();
    // Hidden under the other tab, but alive: a push waits.
    pushes.received.add({'type': 'excuse'});
    await tester.pump(PageRefresher.notificationDelay);
    await tester.pump();
    expect(refreshes, 0);

    shell.goBranch(0);
    await tester.pumpAndSettle();
    expect(refreshes, 1);

    unawaited(router.push('/other'));
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();
    expect(refreshes, 2);
  });

  group('alive is not shown', aliveIsNotShown);

  testWidgets('back from another app: asks again', (tester) async {
    await pump(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(refreshes, 1);
  });

  testWidgets('a window over the app: nothing is asked', (tester) async {
    await pump(tester);

    // The notification permission, the fingerprint sheet, the shade
    // pulled down: the app is never away, so nothing arrived behind it.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(refreshes, 0);
  });

  testWidgets('away once, back twice: asked for the first only', (
    tester,
  ) async {
    await pump(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(refreshes, 1);
  });
}

/// The question the Home review raised: does "shown" mean the current
/// route, or only that the page is somewhere in the navigation stack?
/// The tabs keep every branch alive, so the two are not the same thing.
void aliveIsNotShown() {
  late _Pushes pushes;
  late int refreshes;
  late GoRouter router;
  late StatefulNavigationShell shell;

  setUp(() async {
    pushes = _Pushes();
    refreshes = 0;
    // The group around this one registered its own; these tests send their
    // pushes through this one instead.
    await getIt.reset();
    getIt.registerSingleton<NotificationService>(pushes);
  });

  tearDown(() async {
    await pushes.received.close();
    await getIt.reset();
  });

  /// The parent app's shape: four tabs under one shell, with the chat
  /// pushed over them.
  Future<void> pumpShell(WidgetTester tester) async {
    StatefulShellBranch tab(String path, String label) => StatefulShellBranch(
      routes: [GoRoute(path: path, builder: (_, _) => Text(label))],
    );

    router = GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, _, navigationShell) => shell = navigationShell,
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (_, _) => PageRefresher(
                    path: '/home',
                    onRefresh: () => refreshes++,
                    child: const Text('home'),
                  ),
                ),
              ],
            ),
            tab('/results', 'results'),
            tab('/attendance', 'attendance'),
            tab('/fees', 'fees'),
          ],
        ),
        GoRoute(path: '/chat', builder: (_, _) => const Text('chat')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  /// Home is built and mounted, whether or not the parent can see it.
  bool homeIsAlive() =>
      find.text('home', skipOffstage: false).evaluate().isNotEmpty;

  /// Home is the one on screen.
  bool homeIsVisible() => find.text('home').evaluate().isNotEmpty;

  /// What the current route says, which is what `PageRefresher` goes by.
  String shownPath() => router.routerDelegate.currentConfiguration.uri.path;

  /// A push arrives; did Home ask the school again?
  Future<bool> pushRefreshesHome(WidgetTester tester) async {
    final before = refreshes;
    pushes.received.add({'type': 'announcement'});
    await tester.pump(PageRefresher.notificationDelay);
    await tester.pump();
    return refreshes > before;
  }

  testWidgets('on another tab: Home is alive in the stack, but not shown — '
      'and it is the route, not the stack, that decides', (tester) async {
    await pumpShell(tester);

    expect(homeIsAlive(), isTrue);
    expect(homeIsVisible(), isTrue);
    expect(shownPath(), '/home');
    expect(await pushRefreshesHome(tester), isTrue);

    shell.goBranch(1);
    await tester.pumpAndSettle();

    // The heart of it: still built and mounted (IndexedStack keeps every
    // branch), yet off screen — and treated as not shown.
    expect(homeIsAlive(), isTrue, reason: 'the branch is kept alive');
    expect(homeIsVisible(), isFalse, reason: 'Results is the one on screen');
    expect(shownPath(), '/results');
    expect(
      await pushRefreshesHome(tester),
      isFalse,
      reason: 'being in the stack must not count as being shown',
    );

    shell.goBranch(0);
    await tester.pumpAndSettle();

    expect(shownPath(), '/home');
    expect(homeIsVisible(), isTrue);
  });

  testWidgets('a page pushed over Home: Home is alive and still the shell\'s '
      'location, but the pushed page is what the parent sees', (tester) async {
    await pumpShell(tester);
    unawaited(router.push('/chat'));
    await tester.pumpAndSettle();

    expect(homeIsAlive(), isTrue);
    expect(find.text('chat'), findsOneWidget);
    // The trap: the configuration's own uri still reads /home, because a
    // pushed page keeps its location in its own match. Going by this
    // alone would wrongly call Home shown.
    expect(shownPath(), '/home');
    // `PageRefresher` reads the pushed match instead, so it gets it right.
    expect(
      await pushRefreshesHome(tester),
      isFalse,
      reason: 'the chat is on top: Home must stay quiet',
    );

    router.pop();
    await tester.pumpAndSettle();

    expect(await pushRefreshesHome(tester), isTrue);
  });

  testWidgets('a page pushed over another tab: Home is neither shown nor '
      'refreshed', (tester) async {
    await pumpShell(tester);
    shell.goBranch(2);
    await tester.pumpAndSettle();
    unawaited(router.push('/chat'));
    await tester.pumpAndSettle();

    expect(homeIsAlive(), isTrue);
    expect(homeIsVisible(), isFalse);
    expect(await pushRefreshesHome(tester), isFalse);
  });
}
