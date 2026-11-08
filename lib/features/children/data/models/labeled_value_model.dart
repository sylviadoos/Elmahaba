import 'package:al_mahhaba_school/features/children/domain/entities/labeled_value_entity.dart';

class LabeledValueModel extends LabeledValueEntity {
  const LabeledValueModel({
    required super.value,
    required super.label,
    required super.labelAr,
  });

  /// { "value": "female", "label": "Female", "label_ar": "أنثى" }
  factory LabeledValueModel.fromJson(Map<String, dynamic> json) {
    final value = json['value'] as String? ?? '';
    final label = json['label'] as String? ?? '';
    return LabeledValueModel(
      value: value,
      label: label.isEmpty ? value : label,
      labelAr: json['label_ar'] as String? ?? '',
    );
  }

  /// [json] when it's one (the API sends null for none).
  static LabeledValueModel? maybeFromJson(Object? json) => switch (json) {
    final Map<String, dynamic> json => LabeledValueModel.fromJson(json),
    _ => null,
  };
}
