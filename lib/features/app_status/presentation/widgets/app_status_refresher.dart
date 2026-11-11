import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/features/app_status/presentation/bloc/app_status_bloc.dart';
import 'package:al_mahhaba_school/features/app_status/presentation/bloc/app_status_intent.dart';

/// Asks the school again, while the app runs, whether parents can log in,
/// so "Log in" comes and goes with it instead of waiting for the next
/// launch. The school has no way to tell the app the moment it changes, so
/// this asks on coming back to the app and every [_every] it stays open.
///
/// It wraps the whole app (see `app.dart`): the answer reaches every
/// visitor page, which show the button as the state says.
class AppStatusRefresher extends StatefulWidget {
  const AppStatusRefresher({super.key, required this.child});

  final Widget child;

  @override
  State<AppStatusRefresher> createState() => _AppStatusRefresherState();
}

class _AppStatusRefresherState extends State<AppStatusRefresher>
    with WidgetsBindingObserver {
  /// Soon enough that a visitor waiting on the school sees it without
  /// closing the app, rarely enough to be one small request an hour or so.
  static const Duration _every = Duration(minutes: 5);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Launch asks once already (`app.dart`); this follows it.
    _startAsking();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      // Away: nothing is on screen to change, and the phone sleeps.
      _timer?.cancel();
      return;
    }
    _ask();
    _startAsking();
  }

  void _startAsking() {
    _timer?.cancel();
    _timer = Timer.periodic(_every, (_) => _ask());
  }

  void _ask() {
    if (!mounted) return;
    context.read<AppStatusBloc>().add(const LoadAppStatusIntent());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
