import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/fees/data/models/checkout_item_model.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/checkout_entity.dart';

class CheckoutModel extends CheckoutEntity {
  const CheckoutModel({
    required super.checkoutUrl,
    required super.sessionId,
    required super.items,
    required super.total,
  });

  /// { "checkout_url": "https://pay.skoolexpay…/checkout/cs_9f2c…",
  ///   "checkout_session_id": "cs_9f2c…", "items": […], "total": 5000 }
  factory CheckoutModel.fromJson(Map<String, dynamic> json) {
    final items = jsonObjects(json['items']).map(CheckoutItemModel.fromJson);
    return CheckoutModel(
      checkoutUrl: json['checkout_url'] as String? ?? '',
      sessionId: json['checkout_session_id'] as String? ?? '',
      items: items.toList(),
      // The sum of the items when `total` is missing.
      total:
          jsonDouble(json['total']) ??
          items.fold(0, (sum, item) => sum + item.amount),
    );
  }
}
