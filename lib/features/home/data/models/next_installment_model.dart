import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/next_installment_entity.dart';

class NextInstallmentModel extends NextInstallmentEntity {
  const NextInstallmentModel({
    required super.feeType,
    required super.label,
    required super.amount,
    super.dueDate,
  });

  /// { "fee_type": "مصاريف التعليم والنشاط", "label": "قسط رابع",
  ///   "amount": 3000, "due_date": "2027-02-01" }
  factory NextInstallmentModel.fromJson(Map<String, dynamic> json) =>
      NextInstallmentModel(
        feeType: jsonText(json['fee_type']),
        label: jsonText(json['label']),
        amount: jsonDouble(json['amount']) ?? 0,
        dueDate: DateTime.tryParse(json['due_date'] as String? ?? ''),
      );
}
