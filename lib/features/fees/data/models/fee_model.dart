import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_entity.dart';

class FeeModel extends FeeEntity {
  const FeeModel({
    super.id,
    required super.name,
    required super.bankAccount,
    required super.amount,
    required super.isOptional,
    required super.isPaid,
    required super.canDelete,
    super.isSubscribed,
  });

  /// A line of `fee_statement.mandatory` or `fee_statement.optional`:
  /// { "fee_id": 144, "label": "رسوم كتب", "amount": 1000,
  ///   "bank_account": "••••••••/447", "is_paid": true, "can_delete": false }
  factory FeeModel.fromJson(
    Map<String, dynamic> json, {
    required bool isOptional,
  }) => FeeModel(
    id: json['fee_id'] as int?,
    name: jsonText(json['label']),
    bankAccount: json['bank_account'] as String? ?? '',
    amount: jsonDouble(json['amount']) ?? 0,
    isOptional: isOptional,
    isPaid: json['is_paid'] as bool? ?? false,
    canDelete: json['can_delete'] as bool? ?? false,
    isSubscribed: json['is_subscribed'] as bool?,
  );
}
