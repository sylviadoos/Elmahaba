import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/features/app_status/presentation/bloc/app_status_bloc.dart';
import 'package:al_mahhaba_school/features/app_status/presentation/bloc/app_status_intent.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_state.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';

/// Asks the school again, while a visitor uses the app, whether parents can
/// log in, so "Log in" on the visitor pages comes and goes with it instead
/// of waiting for the next launch. The school has no way to tell the app
/// the moment it changes, so this asks on coming back to the app and every
/// [_every] it stays open — and once a parent logs out, back to the
/// visitor pages.
///
/// Only "Log in" depends on it: a signed-in parent uses the app whatever
/// the school says, so nothing is asked while one is (the splash asks at
/// launch, for a visitor only).
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

  /// Only for a visitor: "Log in" is theirs.
  void _ask() {
    if (!mounted || context.read<ParentViewModel>().state.data != null) {
      return;
    }
    context.read<AppStatusBloc>().add(const LoadAppStatusIntent());
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<ParentViewModel, ParentState>(
        // Logged out: back to the visitor pages, "Log in" as it is now.
        listenWhen: (previous, current) =>
            previous.data != null && current.data == null,
        listener: (_, _) => _ask(),
        child: widget.child,
      );
}
