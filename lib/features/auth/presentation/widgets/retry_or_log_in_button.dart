import 'package:flutter/widgets.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/network/status_code.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/log_out.dart';

/// Under a page's error: "Try again" ([onRetry]) — or "Log out" when the
/// server won't take the session any more (it ended, or the phone it was
/// opened with changed). Loading again can't help then: the parent is
/// signed out and Log in opens, to come back in with.
class RetryOrLogInButton extends StatelessWidget {
  const RetryOrLogInButton({
    super.key,
    required this.exception,
    required this.onRetry,
  });

  /// Why the page didn't load.
  final AppException exception;
  final VoidCallback onRetry;

  /// The server didn't take the session. A 401 says so whatever the API
  /// calls it: these are the screens behind a log in, so there is no other
  /// reading of it — and the school has sent its own words for it
  /// (`{"code": …, "message": "يرجى تسجيل الدخول مرة أخرى."}`), which
  /// aren't an ended session to `DioExceptionHandler` and left the parent
  /// with a "Try again" that could only fail again.
  bool get _sessionEnded =>
      exception is UnauthorizedException ||
      exception.statusCode == StatusCode.expiredToken;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppButton(
      label: _sessionEnded ? l10n.logout : l10n.tryAgain,
      expand: false,
      onPressed: _sessionEnded ? context.logOut : onRetry,
    );
  }
}
