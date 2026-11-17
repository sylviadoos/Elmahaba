import 'package:flutter/widgets.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';

extension VerificationMessage on AppException {
  /// What went wrong sending or checking an SMS code. Firebase's own
  /// messages are technical English, so ours are shown; the school API
  /// sends its own, in the app's language.
  String verificationMessage(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      PhoneVerificationException(code: AuthErrorCodes.wrongCode) =>
        l10n.otpWrongCode,
      PhoneVerificationException(
        code: AuthErrorCodes.codeExpired || AuthErrorCodes.noCodeSent,
      ) =>
        l10n.otpExpired,
      PhoneVerificationException(
        code: AuthErrorCodes.tooManyRequests || AuthErrorCodes.quotaExceeded,
      ) =>
        l10n.tooManyAttempts,
      PhoneVerificationException(code: AuthErrorCodes.invalidPhoneNumber) =>
        l10n.invalidPhoneNumber,
      PhoneVerificationException(:final code)
          when AuthErrorCodes.codeNotSent.contains(code) =>
        l10n.codeSendFailed,
      _ => localizedMessage(context),
    };
  }
}
