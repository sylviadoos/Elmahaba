import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/bus_subscription_entity.dart';

class BusSubscriptionModel extends BusSubscriptionEntity {
  const BusSubscriptionModel({
    required super.available,
    required super.status,
    super.amount,
    super.rejectionReason,
  });

  /// { "available": false, "status": "NONE", "amount": null,
  ///   "rejection_reason": null }
  factory BusSubscriptionModel.fromJson(Map<String, dynamic> json) {
    final reason = jsonText(json['rejection_reason']);
    return BusSubscriptionModel(
      available: json['available'] as bool? ?? false,
      status: json['status'] as String? ?? '',
      amount: jsonDouble(json['amount']),
      rejectionReason: reason.isEmpty ? null : reason,
    );
  }
}
