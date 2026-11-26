import 'package:flutter/widgets.dart';

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/network/status_code.dart';

/// Base type for every error the app knows how to handle.
///
/// [message] is the text sent by the server, when there is one.
/// In the UI, show `exception.localizedMessage(context)`.
sealed class AppException implements Exception {
  const AppException({this.message, this.statusCode});

  final String? message;
  final int? statusCode;

  /// The server's message if it sent one meant for parents, otherwise a
  /// translated default (crashes and untranslated keys are dropped by
  /// `DioExceptionHandler`).
  String localizedMessage(BuildContext context) {
    final l10n = context.l10n;
    return message ??
        switch (this) {
          // The school turned the parents app off for now (503).
          ServerException(code: 'mobile_app_disabled') => l10n.appUnavailable,
          ServerException() => l10n.serverError,
          UnauthorizedException(isAccountWithdrawn: true) =>
            l10n.accountWithdrawn,
          UnauthorizedException(isSessionReplaced: true) =>
            l10n.sessionReplaced,
          UnauthorizedException() => l10n.expiredToken,
          PhoneVerificationException() => l10n.phoneVerificationFailed,
          NetworkException() => l10n.noInternet,
          CancelledException() => l10n.cancelled,
          CacheException() => l10n.unexpectedError,
          UnknownException() => l10n.unknown,
        };
  }

  @override
  String toString() => '$runtimeType($statusCode): ${message ?? '-'}';
}

/// The server answered with an error status (4xx / 5xx).
final class ServerException extends AppException {
  const ServerException({
    super.message,
    super.statusCode,
    this.code,
    this.fieldErrors = const {},
    this.body = const {},
  });

  /// What went wrong, as the API names it: `{"code": "invalid_phone"}`.
  /// Use it to tell errors apart — several share the same status code.
  final String? code;

  /// First error for each invalid field of a 422 response, keyed by the
  /// API's field name: `{'email': 'The email field must be a valid…'}`.
  final Map<String, String> fieldErrors;

  /// The whole error response, for extra fields such as `school_contact`.
  final Map<String, dynamic> body;
}

/// The parent isn't signed in any more: the session is missing or expired,
/// they logged in on another phone ([isSessionReplaced]), or the account
/// itself is closed ([isAccountWithdrawn]). Either way the app forgets the
/// session and opens Log in.
final class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message,
    super.statusCode = StatusCode.expiredToken,
    this.isAccountWithdrawn = false,
    this.isSessionReplaced = false,
  });

  /// The account was logged in on another phone (`session_replaced`): a
  /// parent is signed in on one phone at a time, the last one they logged
  /// in on. Logging in here again works — and signs that phone out.
  final bool isSessionReplaced;

  /// The child was withdrawn from the school, so the account is no longer
  /// available (`account_withdrawn`). Logging in again won't work — only
  /// the school can open it — so the parent is told to contact them.
  final bool isAccountWithdrawn;
}

/// Sending or checking an SMS code failed (Firebase phone auth). [code] is
/// Firebase's, e.g. `invalid-verification-code`, `session-expired`,
/// `too-many-requests`. Its own message is technical English, so it's not
/// kept — show a text chosen by [code].
final class PhoneVerificationException extends AppException {
  const PhoneVerificationException({required this.code});

  final String code;

  @override
  String toString() => 'PhoneVerificationException($code)';
}

/// No internet connection or the request timed out.
final class NetworkException extends AppException {
  const NetworkException();
}

/// The request was cancelled (e.g. the user left the screen).
final class CancelledException extends AppException {
  const CancelledException();
}

/// Reading or writing local storage failed.
final class CacheException extends AppException {
  const CacheException({super.message});
}

/// Anything not covered above.
final class UnknownException extends AppException {
  const UnknownException();
}
