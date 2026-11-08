import 'package:flutter/foundation.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';

/// Outcome of a repository call: [Success] with data, or [Failure] with
/// the error. Build it with [Result.guard]:
///
/// ```dart
/// Future<Result<User>> login(LoginRequest body) => Result.guard(() async {
///   final json = await _api.post(ApiEndpoints.login, data: body.toJson());
///   return User.fromJson(json);
/// });
/// ```
sealed class Result<T> {
  const Result();

  /// Runs [body] and wraps its value — or the error it throws — in a
  /// [Result].
  static Future<Result<T>> guard<T>(Future<T> Function() body) async {
    try {
      return Success(data: await body());
    } on AppException catch (e) {
      return Failure(exception: e);
    } catch (e, stackTrace) {
      debugPrint('Result.guard: $e\n$stackTrace');
      return Failure(exception: const UnknownException());
    }
  }

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      Failure<T>(:final exception) => failure(exception),
    };
  }

  /// Converts the data of a [Success]; a [Failure] is passed on as is.
  Result<R> map<R>(R Function(T data) convert) => switch (this) {
    Success<T>(:final data) => Success(data: convert(data)),
    Failure<T>(:final exception) => Failure(exception: exception),
  };

  /// Runs the next step with the data of a [Success]; a [Failure] skips it.
  ///
  /// ```dart
  /// final verified = await verifyCode(code);
  /// final session = await verified.andThen((token) => register(token));
  /// ```
  Future<Result<R>> andThen<R>(Future<Result<R>> Function(T data) next) =>
      switch (this) {
        Success<T>(:final data) => next(data),
        Failure<T>(:final exception) => Future.value(
          Failure(exception: exception),
        ),
      };
}

final class Success<T> extends Result<T> {
  final T data;
  const Success({required this.data});
}

final class Failure<T> extends Result<T> {
  final AppException exception;
  const Failure({required this.exception});
}
