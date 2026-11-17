import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_router.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/notifications/notification_link.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';
import 'package:al_mahhaba_school/core/widgets/page_refresher.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_state.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_link_navigation.dart';

/// Opens what the parent tapped in a notification: the chat for a message
/// the school sent, or the screen the push names (see [notificationLink]).
///
/// It wraps the whole app (see `app.dart`), above `MaterialApp.router`, so
/// it goes through the router itself — `GoRouter.of(context)` can't reach
/// it from here.
///
/// A tap waits its turn when it can't be opened yet, and nothing is lost:
/// - the push that *opened* the app arrives while the splash is still
///   counting down, and the splash would send the parent to Home over it;
/// - a parent whose session is being checked isn't signed in yet, and the
///   chat would open on a parent that isn't there.
///
/// So it holds the tap until a parent is signed in and the splash is gone,
/// then opens it.
class NotificationRouter extends StatefulWidget {
  const NotificationRouter({super.key, required this.child, this.router});

  final Widget child;

  /// The app's router; [appRouter] unless a test passes its own.
  final GoRouter? router;

  @override
  State<NotificationRouter> createState() => _NotificationRouterState();
}

class _NotificationRouterState extends State<NotificationRouter> {
  StreamSubscription<Map<String, dynamic>>? _taps;

  /// The tapped notification waiting to be opened, if any.
  Map<String, dynamic>? _pending;

  GoRouter get _router => widget.router ?? appRouter;

  @override
  void initState() {
    super.initState();
    _taps = getIt<NotificationService>().onTap.listen(_tapped);
    // The splash ending is a route change, not a state this widget sees.
    _router.routerDelegate.addListener(_openPending);
  }

  @override
  void dispose() {
    unawaited(_taps?.cancel());
    _router.routerDelegate.removeListener(_openPending);
    super.dispose();
  }

  void _tapped(Map<String, dynamic> data) {
    _pending = data;
    _openPending();
  }

  /// The parent is signed in once the splash has checked the session.
  bool get _signedIn =>
      mounted && context.read<ParentViewModel>().state.data != null;

  /// Still on the splash: it is about to send the parent somewhere else,
  /// over anything opened now.
  bool get _onSplash =>
      shownRoutePath(_router.routerDelegate) == AppRoutes.splash;

  void _openPending() {
    final data = _pending;
    if (data == null || !_signedIn || _onSplash) return;
    _pending = null;
    // What says it can be opened is the router changing (the splash
    // ending): opening during that change would be a route pushed while
    // one is being settled, so it waits for the frame to end.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _open(data);
    });
  }

  void _open(Map<String, dynamic> data) {
    final link = notificationLink(data);
    if (link != null) {
      _router.openChatLink(link);
      return;
    }
    // The chat, where everything the school sends is — unless it's open
    // already, which a second copy of it would only cover.
    if (shownRoutePath(_router.routerDelegate) != AppRoutes.chat) {
      _router.push(AppRoutes.chat);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<ParentViewModel, ParentState>(
        // Signed in at last: a tap that came before can be opened now.
        listenWhen: (previous, current) =>
            previous.data?.id != current.data?.id && current.data != null,
        listener: (context, _) => _openPending(),
        child: widget.child,
      );
}
