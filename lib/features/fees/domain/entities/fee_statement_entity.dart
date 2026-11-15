import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/fees/domain/entities/bus_subscription_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_installment_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_student_entity.dart';

/// A child's fees for the school year: who for, every fee, the totals and
/// the installments.
class FeeStatementEntity extends Equatable {
  const FeeStatementEntity({
    required this.student,
    required this.payOnlineEnabled,
    required this.fees,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingBalance,
    required this.installments,
    required this.busSubscription,
    required this.canChangeOptionalFees,
  });

  final FeeStudentEntity student;

  /// Whether paying online is open.
  final bool payOnlineEnabled;
  final List<FeeEntity> fees;

  /// In EGP, with the optional fees subscribed to.
  final double totalAmount;
  final double paidAmount;
  final double remainingBalance;
  final List<FeeInstallmentEntity> installments;
  final BusSubscriptionEntity busSubscription;

  /// Whether the parent can subscribe to or drop an optional fee.
  final bool canChangeOptionalFees;

  @override
  List<Object?> get props => [
    student,
    payOnlineEnabled,
    fees,
    totalAmount,
    paidAmount,
    remainingBalance,
    installments,
    busSubscription,
    canChangeOptionalFees,
  ];
}
