import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/checkout_item_entity.dart';

class CheckoutItemModel extends CheckoutItemEntity {
  const CheckoutItemModel({
    required super.name,
    required super.amount,
    super.dueDate,
  });

  /// { "name": "مصاريف التعليم والنشاط - قسط ثانى", "amount": 5000,
  ///   "due_date": "2026-10-01" }
  factory CheckoutItemModel.fromJson(Map<String, dynamic> json) =>
      CheckoutItemModel(
        name: jsonText(json['name']),
        amount: jsonDouble(json['amount']) ?? 0,
        dueDate: DateTime.tryParse(json['due_date'] as String? ?? ''),
      );
}
