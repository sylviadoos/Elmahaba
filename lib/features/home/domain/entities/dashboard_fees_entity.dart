import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/home/domain/entities/next_installment_entity.dart';

/// A child's fees for the school year: the totals, in EGP, and the next
/// installment.
class DashboardFeesEntity extends Equatable {
  const DashboardFeesEntity({
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingBalance,
    this.nextInstallment,
  });

  final double totalAmount;
  final double paidAmount;
  final double remainingBalance;

  /// null when there's none.
  final NextInstallmentEntity? nextInstallment;

  @override
  List<Object?> get props => [
    totalAmount,
    paidAmount,
    remainingBalance,
    nextInstallment,
  ];
}
