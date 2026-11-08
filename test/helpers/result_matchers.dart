import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';

/// A [Success] holding [data] (or data matching it).
Matcher isSuccess<T>(Object? data) =>
    isA<Success<T>>().having((success) => success.data, 'data', data);

/// A [Failure] holding an [E].
Matcher isFailure<E extends AppException>() => isA<Failure<Object?>>().having(
  (failure) => failure.exception,
  'exception',
  isA<E>(),
);
