import 'package:equatable/equatable.dart';

/// One installment in an online payment.
class CheckoutItemEntity extends Equatable {
  const CheckoutItemEntity({
    required this.name,
    required this.amount,
    this.dueDate,
  });

  /// e.g. "مصاريف التعليم والنشاط - قسط ثانى".
  final String name;

  /// In EGP.
  final double amount;
  final DateTime? dueDate;

  @override
  List<Object?> get props => [name, amount, dueDate];
}
