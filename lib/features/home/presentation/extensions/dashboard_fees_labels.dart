import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/installment_status.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/dashboard_fees_entity.dart';

extension DashboardFeesLabels on DashboardFeesEntity {
  /// Everything overdue added up, "EGP 7,000"; otherwise the installment's
  /// amount; a dash without one.
  String amountLabel(BuildContext context) {
    final installment = this.installment;
    final amount = hasOverdue ? overdueTotal : installment?.amount;
    if (amount == null) return '—';
    final locale = Localizations.localeOf(context).toString();
    return context.l10n.egpAmount(
      NumberFormat.decimalPattern(locale).format(amount),
    );
  }

  /// "2 overdue installments" when more than one is; otherwise which
  /// installment, "قسط رابع · مصاريف التعليم والنشاط"; "All fees paid" or
  /// "No fees yet" without one.
  String subtitle(BuildContext context) {
    final l10n = context.l10n;
    if (hasOverdue && overdueCount > 1) {
      return l10n.overdueInstallmentsCount(overdueCount);
    }
    final installment = this.installment;
    if (installment == null) {
      return status == InstallmentStatus.paid
          ? l10n.allFeesPaid
          : l10n.noFeesYet;
    }
    final parts = [installment.label, installment.feeType];
    return parts.where((part) => part.isNotEmpty).join(' · ');
  }

  /// Where it stands: "Due Feb 1", "Overdue since Oct 1", "Payment in
  /// progress"…; null with nothing to say.
  String? note(BuildContext context) {
    final l10n = context.l10n;
    final installment = this.installment;
    if (installment == null) return null;
    final dueDate = installment.dueDate;
    final date = dueDate == null
        ? null
        : DateFormat.MMMd(
            Localizations.localeOf(context).toString(),
          ).format(dueDate);
    return switch (status) {
      InstallmentStatus.overdue when date != null => l10n.feesOverdueSince(
        date,
      ),
      InstallmentStatus.overdue => l10n.overdue,
      InstallmentStatus.processing => l10n.paymentInProgress,
      InstallmentStatus.underSettlement => l10n.underSettlement,
      InstallmentStatus.paid => l10n.paid,
      InstallmentStatus.upcoming ||
      InstallmentStatus.unknown => date == null ? null : l10n.feesDueOn(date),
    };
  }
}
