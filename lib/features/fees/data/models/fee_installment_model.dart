import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_installment_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/installment_status.dart';

class FeeInstallmentModel extends FeeInstallmentEntity {
  const FeeInstallmentModel({
    required super.feeName,
    required super.label,
    super.dueDate,
    required super.bankAccount,
    super.amount,
    required super.status,
    required super.statusLabel,
    required super.canPay,
    required super.payKey,
    super.requires,
  });

  /// { "pay_key": "8472|قسط ثانى|2026-10-01",
  ///   "fee_type": "مصاريف التعليم والنشاط", "installment": "قسط ثانى",
  ///   "due_date": "2026-10-01", "bank_account": "••••••••/446",
  ///   "amount": 5000, "status": "UNDER_PROCESSING",
  ///   "status_label": "دفع إلكتروني – جارى التحقق", "can_pay": false,
  ///   "locked": true, "locked_reason": "…",
  ///   "requires": ["8472|قسط اول|2026-08-16"] }
  factory FeeInstallmentModel.fromJson(Map<String, dynamic> json) {
    final payKey = json['pay_key'] as String? ?? '';
    // Locked: only together with the earlier ones in `requires`.
    final locked = json['locked'] as bool? ?? false;

    return FeeInstallmentModel(
      feeName: jsonText(json['fee_type']),
      label: jsonText(json['installment']),
      dueDate: DateTime.tryParse(json['due_date'] as String? ?? ''),
      bankAccount: json['bank_account'] as String? ?? '',
      amount: jsonDouble(json['amount']),
      status: switch (json['status']) {
        'PAID' => InstallmentStatus.paid,
        'OVERDUE' => InstallmentStatus.overdue,
        'UPCOMING' => InstallmentStatus.upcoming,
        'UNDER_PROCESSING' => InstallmentStatus.processing,
        'UNDER_SETTLEMENT' => InstallmentStatus.underSettlement,
        _ => InstallmentStatus.unknown,
      },
      statusLabel: jsonText(json['status_label']),
      canPay: (json['can_pay'] as bool? ?? false) && payKey.isNotEmpty,
      payKey: payKey,
      requires: [
        if (locked && json['requires'] is List)
          for (final key in json['requires'] as List)
            if (key is String && key.isNotEmpty) key,
      ],
    );
  }
}
