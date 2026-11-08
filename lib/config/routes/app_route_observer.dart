import 'package:flutter/widgets.dart';

/// Tells the pages that subscribe (`RouteAware`) when they show again: the
/// page above them closed, however it was opened or what replaced it.
/// (A page that's replaced never answers the `await context.push` that
/// opened it.)
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
