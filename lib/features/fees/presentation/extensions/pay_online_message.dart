import 'package:flutter/widgets.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/fees/domain/fees_error_codes.dart';

extension PayOnlineMessage on AppException {
  /// Why paying online didn't start. Paid out of order: the school's own
  /// sentence, as its website shows it, naming the fee to pay first
  /// ("يجب دفع مصاريف التعليم والنشاط أولاً قبل دفع مصاريف الباص.") — not
  /// the general "Earlier installments must be paid first.".
  String payOnlineMessage(BuildContext context) => switch (this) {
    ServerException(
      code: FeesErrorCodes.payOnlineInstallmentOrder,
      body: {'website_message': final String reason},
    )
        when reason.trim().isNotEmpty =>
      reason.trim(),
    _ => localizedMessage(context),
  };
}
