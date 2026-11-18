import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';

/// Back from a parent page goes Home, however many pages the parent opened
/// on the way: from Fees, after the chat and Attendance, one back is Home,
/// not three. It covers the phone's back button and the arrow in the
/// page's header (`AppBackButton` asks [of]).
///
/// The router wraps every parent page in one, apart from:
/// - Home itself — back there leaves the app, as always;
/// - the tabs — they share one route, so `ParentShellPage` has its own;
/// - the chat's photo and file viewers — back there closes what's open and
///   leaves the chat underneath, where the parent was reading;
/// - an excuse (new, or its details) — back is Attendance, which opened it.
///
/// Log in and sign up aren't parent pages: there's no Home to go to yet.
class HomeOnBack extends StatelessWidget {
  const HomeOnBack({super.key, required this.child});

  final Widget child;

  /// Whether back from the page around [context] goes Home.
  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_BackGoesHome>() != null;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Taken over: going Home drops the pages under this one with it.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: _BackGoesHome(child: child),
    );
  }
}

/// Marks the pages under a [HomeOnBack], for [HomeOnBack.of].
class _BackGoesHome extends InheritedWidget {
  const _BackGoesHome({required super.child});

  @override
  bool updateShouldNotify(_BackGoesHome oldWidget) => false;
}
