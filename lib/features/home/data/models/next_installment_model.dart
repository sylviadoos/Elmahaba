import 'package:al_mahhaba_school/features/home/domain/entities/next_installment_entity.dart';

class NextInstallmentModel extends NextInstallmentEntity {
  const NextInstallmentModel({
    required super.label,
    required super.amount,
    super.dueDate,
    required super.displayStatus,
  });

  factory NextInstallmentModel.fromJson(Map<String, dynamic> json) =>
      NextInstallmentModel(
        label: json['label'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        // "2026-10-01"
        dueDate: DateTime.tryParse(json['due_date'] as String? ?? ''),
        displayStatus: json['display_status'] as String? ?? '',
      );
}
