import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';

/// A loading [BaseState].
final Matcher isLoadingState = isA<BaseState<Object?>>().having(
  (state) => state.state,
  'state',
  StateType.loading,
);

/// A success [BaseState] whose data is (or matches) [data].
Matcher isSuccessState(Object? data) => isA<BaseState<Object?>>()
    .having((state) => state.state, 'state', StateType.success)
    .having((state) => state.data, 'data', data);

/// An error [BaseState] holding an [E].
Matcher isErrorState<E extends AppException>() => isA<BaseState<Object?>>()
    .having((state) => state.state, 'state', StateType.error)
    .having((state) => state.exception, 'exception', isA<E>());
