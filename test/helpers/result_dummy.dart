import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';

/// [Result] is sealed, so mockito can't make one up for a mocked method
/// that returns it: call this (in `setUpAll`) for each `Result<T>` mocked.
void provideResultDummy<T>() =>
    provideDummy<Result<T>>(Failure<T>(exception: const UnknownException()));
