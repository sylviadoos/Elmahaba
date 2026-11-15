import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/fees/domain/entities/installment_status.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/next_installment_entity.dart';

/// A child's fees on Home: the installment the school points to (the next
/// one to pay), where it stands, and what's overdue altogether.
class DashboardFeesEntity extends Equatable {
  const DashboardFeesEntity({
    required this.status,
    this.installment,
    this.overdueCount = 0,
    this.overdueTotal = 0,
  });

  /// [installment]'s, e.g. upcoming or overdue; paid with none left.
  final InstallmentStatus status;

  /// null when there's none to pay.
  final NextInstallmentEntity? installment;

  /// How many installments are overdue, of every kind of fee (school,
  /// bus…).
  final int overdueCount;

  /// What they add up to, in EGP.
  final num overdueTotal;

  /// Something is overdue: Home shows all of it, not just [installment].
  bool get hasOverdue => overdueCount > 0 && overdueTotal > 0;

  @override
  List<Object?> get props => [status, installment, overdueCount, overdueTotal];
}
