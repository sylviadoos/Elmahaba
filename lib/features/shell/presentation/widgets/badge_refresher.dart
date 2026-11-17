import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_router.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';
import 'package:al_mahhaba_school/core/widgets/page_refresher.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_unread_context.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/children_context.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';

/// Keeps the badge on Chat and the dot on Complaints right while the app
/// runs: each notification that arrives asks the school what's new, and so
/// does coming back to the app, for the ones that arrived while it was
/// away. Without this they would only be right at launch — a parent would
/// have to close the app and open it again to see a new message.
///
/// A push carries no counts, so what it says isn't read: it only says
/// something happened. It wraps the whole app (see `app.dart`), so the
/// badges follow whichever page the parent is on.
///
/// Home asks the school for the same dashboard the chat badge is counted
/// from, and tells the badge what it says (see `HomePage`), so asking here
/// as well would be the very same request twice. Nothing is asked while
/// Home is the page shown; underneath, Home stays quiet and this is what
/// keeps the badge right.
class BadgeRefresher extends StatefulWidget {
  const BadgeRefresher({super.key, required this.child, this.router});

  final Widget child;

  /// The app's router, for telling whether Home is the page shown. This
  /// sits above `MaterialApp.router`, where `GoRouter.of` can't reach it,
  /// so it goes to [appRouter] unless a test passes its own.
  final GoRouter? router;

  @override
  State<BadgeRefresher> createState() => _BadgeRefresherState();
}

class _BadgeRefresherState extends State<BadgeRefresher>
    with WidgetsBindingObserver {
  StreamSubscription<Map<String, dynamic>>? _notifications;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notifications = getIt<NotificationService>().onReceived.listen(
      (_) => _refresh(),
    );
  }

  @override
  void dispose() {
    unawaited(_notifications?.cancel());
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Back from the home screen or another app: pushes may have arrived
  /// while it was away, and those don't reach [NotificationService].
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  /// Nothing to count for a visitor, and the API would answer 401.
  bool get _signedIn =>
      mounted && context.read<ParentViewModel>().state.data != null;

  /// Home is the page on screen, so it is already asking for the dashboard
  /// the badge is counted from and will pass the count on. Only the page
  /// truly on top counts: with the chat open over Home, Home stays quiet,
  /// so this must not skip (see [shownRoutePath]).
  bool get _homeAsksInstead =>
      shownRoutePath((widget.router ?? appRouter).routerDelegate) ==
      AppRoutes.home;

  void _refresh() {
    if (!_signedIn || _homeAsksInstead) return;
    context.loadChatUnread();
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<ChildrenViewModel, ChildrenState>(
        // The badge counts the child every page shows: another one picked,
        // or the children here at last.
        listenWhen: (previous, current) =>
            current.showsOtherChildThan(previous),
        listener: (context, _) => _refresh(),
        child: widget.child,
      );
}
