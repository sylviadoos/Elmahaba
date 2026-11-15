import 'package:equatable/equatable.dart';

/// The fees installment Home shows: the next one to pay.
class NextInstallmentEntity extends Equatable {
  const NextInstallmentEntity({
    required this.feeType,
    required this.label,
    required this.amount,
    this.dueDate,
  });

  /// What it's for, e.g. "مصاريف التعليم والنشاط".
  final String feeType;

  /// As the school wrote it, e.g. "قسط رابع".
  final String label;

  /// In EGP.
  final double amount;

  /// null when the API doesn't give one.
  final DateTime? dueDate;

  @override
  List<Object?> get props => [feeType, label, amount, dueDate];
}
