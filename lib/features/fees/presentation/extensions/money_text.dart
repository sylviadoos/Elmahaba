import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

extension MoneyText on BuildContext {
  /// "18,000", in the app's language.
  String money(num amount) => NumberFormat.decimalPattern(
    Localizations.localeOf(this).toString(),
  ).format(amount);

  /// "EGP 8,000" / "8,000 ج.م".
  String egp(num amount) => l10n.egpAmount(money(amount));
}
