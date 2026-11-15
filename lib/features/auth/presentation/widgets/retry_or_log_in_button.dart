import 'package:flutter/widgets.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/log_out.dart';

/// Under a page's error: "Try again" ([onRetry]) — or "Log in" when the
/// server says the session ended (e.g. the mobile it was opened with
/// changed). Trying again can't help then, so it signs the parent out and
/// opens Log in.
class RetryOrLogInButton extends StatelessWidget {
  const RetryOrLogInButton({
    super.key,
    required this.exception,
    required this.onRetry,
  });

  /// Why the page didn't load.
  final AppException exception;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sessionEnded = exception is UnauthorizedException;

    return AppButton(
      label: sessionEnded ? l10n.login : l10n.tryAgain,
      expand: false,
      onPressed: sessionEnded ? context.logOut : onRetry,
    );
  }
}
