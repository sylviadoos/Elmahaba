import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/fees/domain/entities/installment_status.dart';

/// One part of a fee, due on a date.
class FeeInstallmentEntity extends Equatable {
  const FeeInstallmentEntity({
    required this.feeName,
    required this.label,
    this.dueDate,
    required this.bankAccount,
    this.amount,
    required this.status,
    required this.statusLabel,
    required this.canPay,
    required this.payKey,
    this.requires = const [],
  });

  /// The fee it's part of, as the school wrote it, e.g. "رسوم كتب".
  final String feeName;

  /// e.g. "قسط اول".
  final String label;
  final DateTime? dueDate;

  /// The bank account it's paid into, masked, e.g. "••••••••/446".
  final String bankAccount;

  /// In EGP; null when the school hasn't set it (under settlement).
  final double? amount;
  final InstallmentStatus status;

  /// The school's own words for [status], e.g. "مدفوع" — shown for a
  /// status the app doesn't know.
  final String statusLabel;

  /// Can be ticked to pay now, as the school says, with a [payKey] to pay
  /// it by.
  final bool canPay;

  /// Names it when paying online, e.g. "8472|قسط اول|2026-08-16".
  final String payKey;

  /// The `payKey`s of the earlier installments still unpaid: it's paid in
  /// order only together with them. Empty when nothing comes before it.
  final List<String> requires;

  /// Ticked with the installments in [picked] (`payKey`s), it's paid in
  /// order: every earlier one it needs is ticked too.
  bool isInOrderWith(Set<String> picked) => requires.every(picked.contains);

  @override
  List<Object?> get props => [
    feeName,
    label,
    dueDate,
    bankAccount,
    amount,
    status,
    statusLabel,
    canPay,
    payKey,
    requires,
  ];
}
