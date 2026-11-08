import 'package:al_mahhaba_school/features/home/data/models/next_installment_model.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/dashboard_fees_entity.dart';

class DashboardFeesModel extends DashboardFeesEntity {
  const DashboardFeesModel({
    required super.totalAmount,
    required super.paidAmount,
    required super.remainingBalance,
    super.nextInstallment,
  });

  /// { "payment_summary": { "total_amount": 19000, … },
  ///   "next_installment": {…} or null } — with a `payment_summary`.
  factory DashboardFeesModel.fromJson(Map<String, dynamic> json) {
    final summary = json['payment_summary'] as Map<String, dynamic>;

    return DashboardFeesModel(
      totalAmount: (summary['total_amount'] as num?)?.toDouble() ?? 0,
      paidAmount: (summary['paid_amount'] as num?)?.toDouble() ?? 0,
      remainingBalance: (summary['remaining_balance'] as num?)?.toDouble() ?? 0,
      nextInstallment: switch (json['next_installment']) {
        final Map<String, dynamic> next => NextInstallmentModel.fromJson(next),
        _ => null,
      },
    );
  }
}
