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
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  }

  testWidgets('a notification while shown: asks again', (tester) async {
    await pump(tester);
    expect(refreshes, 0);

    pushes.received.add({'type': 'excuse'});
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

  testWidgets('a notification while hidden waits for it to show', (
    tester,
  ) async {
    await pump(tester);
    unawaited(router.push('/other'));
    await tester.pumpAndSettle();

    pushes.received.add({'type': 'excuse'});
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

  testWidgets('back to the app: asks again', (tester) async {
    await pump(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(refreshes, 1);
  });
}
