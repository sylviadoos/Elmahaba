import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/fees/data/models/bus_subscription_model.dart';
import 'package:al_mahhaba_school/features/fees/data/models/fee_installment_model.dart';
import 'package:al_mahhaba_school/features/fees/data/models/fee_model.dart';
import 'package:al_mahhaba_school/features/fees/data/models/fee_student_model.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_statement_entity.dart';

/// The `data` of `GET v1/parent/children/{child_id}/fees`.
///
/// Missing amounts read as 0 and missing lists as empty; without a
/// `payment_summary`, the total is `fee_statement.total_due`.
class FeeStatementModel extends FeeStatementEntity {
  const FeeStatementModel({
    required super.student,
    required super.payOnlineEnabled,
    required super.fees,
    required super.totalAmount,
    required super.paidAmount,
    required super.remainingBalance,
    required super.installments,
    required super.busSubscription,
    required super.canChangeOptionalFees,
  });

  factory FeeStatementModel.fromJson(Map<String, dynamic> json) {
    final summary = json['payment_summary'] as Map<String, dynamic>? ?? {};
    final feeStatement =
        json['fee_statement'] as Map<String, dynamic>? ?? const {};
    final total =
        jsonDouble(summary['total_amount']) ??
        jsonDouble(feeStatement['total_due']) ??
        0;
    final paid = jsonDouble(summary['paid_amount']) ?? 0;

    return FeeStatementModel(
      student: FeeStudentModel.fromJson(
        json['student'] as Map<String, dynamic>? ?? const {},
        id: json['student_id'] as int? ?? 0,
      ),
      payOnlineEnabled: json['pay_online_enabled'] as bool? ?? false,
      fees: [
        for (final fee in jsonObjects(feeStatement['mandatory']))
          FeeModel.fromJson(fee, isOptional: false),
        for (final fee in jsonObjects(feeStatement['optional']))
          FeeModel.fromJson(fee, isOptional: true),
      ],
      totalAmount: total,
      paidAmount: paid,
      remainingBalance:
          jsonDouble(summary['remaining_balance']) ??
          (total - paid).clamp(0, total),
      installments: [
        for (final installment in jsonObjects(json['installments']))
          FeeInstallmentModel.fromJson(installment),
      ],
      busSubscription: BusSubscriptionModel.fromJson(
        json['bus_subscription'] as Map<String, dynamic>? ?? const {},
      ),
      canChangeOptionalFees: json['can_change_optional_fees'] as bool? ?? false,
    );
  }
}
