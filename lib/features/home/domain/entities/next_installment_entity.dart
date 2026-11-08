import 'package:equatable/equatable.dart';

/// The next fees installment to pay.
class NextInstallmentEntity extends Equatable {
  const NextInstallmentEntity({
    required this.label,
    required this.amount,
    this.dueDate,
    required this.displayStatus,
  });

  /// As the school wrote it, e.g. "قسط ثانى".
  final String label;

  /// In EGP.
  final double amount;

  /// null when the API doesn't give one.
  final DateTime? dueDate;

  /// e.g. "OVERDUE".
  final String displayStatus;

  @override
  List<Object?> get props => [label, amount, dueDate, displayStatus];
}
