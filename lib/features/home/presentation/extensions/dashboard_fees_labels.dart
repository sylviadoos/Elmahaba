import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/dashboard_fees_entity.dart';

extension DashboardFeesLabels on DashboardFeesEntity {
  /// "EGP 5,000 due Oct 1", "… overdue since Oct 1", or what's left.
  String note(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    String money(double amount) =>
        l10n.egpAmount(NumberFormat.decimalPattern(locale).format(amount));

    final next = nextInstallment;
    if (next == null) {
      return remainingBalance > 0
          ? '${l10n.remaining} ${money(remainingBalance)}'
          : l10n.allFeesPaid;
    }
    final amount = money(next.amount);
    final dueDate = next.dueDate;
    if (dueDate == null) {
      return next.label.isEmpty ? amount : '${next.label} · $amount';
    }
    final date = DateFormat.MMMd(locale).format(dueDate);
    return next.displayStatus == 'OVERDUE'
        ? l10n.amountOverdueSince(amount, date)
        : l10n.amountDueOn(amount, date);
  }
}
