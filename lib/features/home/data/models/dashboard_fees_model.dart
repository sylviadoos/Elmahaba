import 'package:al_mahhaba_school/features/fees/data/models/installment_status_json.dart';
import 'package:al_mahhaba_school/features/home/data/models/next_installment_model.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/dashboard_fees_entity.dart';

class DashboardFeesModel extends DashboardFeesEntity {
  const DashboardFeesModel({
    required super.status,
    super.installment,
    super.overdueCount,
    super.overdueTotal,
  });

  /// { "selection_status": "OVERDUE", "selected_installment": {…} or null,
  ///   "overdue_installments": [{ "amount": 5000, … }, …],
  ///   "overdue_count": 2, "overdue_total": 7000 }. Without the count or the
  /// total, they're worked out from the installments.
  factory DashboardFeesModel.fromJson(Map<String, dynamic> json) {
    final overdue = [
      for (final installment
          in json['overdue_installments'] as List<dynamic>? ?? const [])
        if (installment is Map<String, dynamic>) installment,
    ];
    return DashboardFeesModel(
      status: installmentStatusFromJson(json['selection_status']),
      installment: switch (json['selected_installment']) {
        final Map<String, dynamic> installment => NextInstallmentModel.fromJson(
          installment,
        ),
        _ => null,
      },
      overdueCount: json['overdue_count'] as int? ?? overdue.length,
      overdueTotal:
          json['overdue_total'] as num? ??
          overdue.fold<num>(0, (sum, i) => sum + (i['amount'] as num? ?? 0)),
    );
  }
}
