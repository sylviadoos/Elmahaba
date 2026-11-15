import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';

/// The path of the page the parent is actually looking at.
///
/// Not the same as the router's own location: a page opened with `push`
/// (the chat, an excuse…) leaves [RouteMatchList.uri] at the page under
/// it, with its own location in its match. Reading that uri alone would
/// call Home "shown" while the chat covers it — so anything asking "is
/// this page the one on screen?" must go through here, never through
/// `currentConfiguration.uri` directly.
///
/// A branch of the tabs that is alive but off screen is not shown either:
/// switching tabs changes the location.
String shownRoutePath(GoRouterDelegate router) {
  final configuration = router.currentConfiguration;
  final top = configuration.lastOrNull;
  final shown = top is ImperativeRouteMatch ? top.matches : configuration;
  return shown.uri.path;
}

/// Calls [onRefresh] whenever the page at [path] may show something that
/// changed at school, so it's never stale and never asked on a timer:
/// - a notification arrives while it's shown (the school posted, accepted
///   an excuse, changed something…);
/// - the app comes back to the front (notifications that arrived while it
///   was away don't reach the app);
/// - the page shows again: back from a page opened over it, or from
///   another tab (tabs stay alive underneath).
///
/// A notification while the page is hidden waits for it to show again.
class PageRefresher extends StatefulWidget {
  const PageRefresher({
    super.key,
    required this.path,
    required this.onRefresh,
    required this.child,
  });

  /// The page's route, e.g. `AppRoutes.home`.
  final String path;
  final VoidCallback onRefresh;
  final Widget child;

  @override
  State<PageRefresher> createState() => _PageRefresherState();
}

class _PageRefresherState extends State<PageRefresher>
    with WidgetsBindingObserver {
  StreamSubscription<Map<String, dynamic>>? _notifications;
  GoRouterDelegate? _router;

  /// Whether the page is the one shown, as of the router's last change.
  bool _shown = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notifications = getIt<NotificationService>().onReceived.listen(
      (_) => _refreshIfShown(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.of(context).routerDelegate;
    if (router == _router) return;
    _router?.removeListener(_onRouteChanged);
    _router = router..addListener(_onRouteChanged);
    _shown = _isShown(router);
  }

  @override
  void dispose() {
    unawaited(_notifications?.cancel());
    _router?.removeListener(_onRouteChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshIfShown();
  }

  void _onRouteChanged() {
    final router = _router;
    if (router == null) return;
    final shown = _isShown(router);
    final cameBack = shown && !_shown;
    _shown = shown;
    if (cameBack && mounted) widget.onRefresh();
  }

  void _refreshIfShown() {
    if (_shown && mounted) widget.onRefresh();
  }

  /// Whether this page is the one on top (see [shownRoutePath]).
  bool _isShown(GoRouterDelegate router) =>
      shownRoutePath(router) == widget.path;

  @override
  Widget build(BuildContext context) => widget.child;
}
