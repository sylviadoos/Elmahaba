import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// MVI: the view sends intents ([I], with `add`), draws the one state [S],
/// and reacts to effects [E] — what happens once and isn't state: a snack
/// bar, opening a file, clearing a text field. Listen to them with
/// `BlocEffectListener`.
abstract class BaseBloc<I, S, E> extends Bloc<I, S> {
  BaseBloc(super.initialState);

  final StreamController<E> _effects = StreamController.broadcast();

  /// Each effect, once, to whoever listens when it happens.
  Stream<E> get effects => _effects.stream;

  @protected
  void emitEffect(E effect) {
    if (!_effects.isClosed) _effects.add(effect);
  }

  @override
  Future<void> close() async {
    await _effects.close();
    return super.close();
  }
}
