import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/core/base/base_bloc.dart';

/// Calls [listener] with each effect of the [B] above it (see [BaseBloc]),
/// while it's on screen.
class BlocEffectListener<B extends BaseBloc<Object?, Object?, E>, E>
    extends StatefulWidget {
  const BlocEffectListener({
    super.key,
    required this.listener,
    required this.child,
  });

  final void Function(BuildContext context, E effect) listener;
  final Widget child;

  @override
  State<BlocEffectListener<B, E>> createState() =>
      _BlocEffectListenerState<B, E>();
}

class _BlocEffectListenerState<B extends BaseBloc<Object?, Object?, E>, E>
    extends State<BlocEffectListener<B, E>> {
  late final StreamSubscription<E> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = context.read<B>().effects.listen((effect) {
      if (mounted) widget.listener(context, effect);
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
