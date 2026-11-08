import 'package:flutter/material.dart';

/// How pages open and close: each platform's own transition (Android's fade
/// forwards, iOS's slide with its swipe back), only quicker than Flutter's
/// (450 ms on Android, 500 ms on iOS).
abstract final class AppPageTransitions {
  static const Duration duration = Duration(milliseconds: 250);

  static const PageTransitionsTheme theme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _Quick(PredictiveBackPageTransitionsBuilder()),
      TargetPlatform.iOS: _Quick(CupertinoPageTransitionsBuilder()),
      TargetPlatform.macOS: _Quick(CupertinoPageTransitionsBuilder()),
      TargetPlatform.windows: _Quick(ZoomPageTransitionsBuilder()),
      TargetPlatform.linux: _Quick(ZoomPageTransitionsBuilder()),
    },
  );
}

/// [base]'s transition in [AppPageTransitions.duration].
class _Quick extends PageTransitionsBuilder {
  const _Quick(this.base);

  final PageTransitionsBuilder base;

  @override
  Duration get transitionDuration => AppPageTransitions.duration;

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      base.delegatedTransition;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => base.buildTransitions(
    route,
    context,
    animation,
    secondaryAnimation,
    child,
  );
}
