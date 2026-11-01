import 'package:flutter/foundation.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';

/// Outcome of a repository call: [Success] with data, or [Failure] with
/// the error. Build it with [Result.guard]:
///
/// ```dart
/// Future<Result<User>> login(LoginRequest body) => Result.guard(() async {
///   final json = await _api.post(ApiEndpoints.signin, data: body.toJson());
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
}

final class Success<T> extends Result<T> {
  final T data;
  const Success({required this.data});
}

final class Failure<T> extends Result<T> {
  final AppException exception;
  const Failure({required this.exception});
}
