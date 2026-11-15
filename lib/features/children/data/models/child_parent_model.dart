import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_parent_entity.dart';

class ChildParentModel extends ChildParentEntity {
  const ChildParentModel({
    required super.name,
    required super.nameAr,
    super.job,
    super.education,
    super.phone,
  });

  /// { "name": "مينا ناجى مينا", "name_ar": null, "job": null,
  ///   "education": null, "phone": "01285112570" }
  factory ChildParentModel.fromJson(Map<String, dynamic> json) =>
      ChildParentModel(
        name: jsonText(json['name']),
        nameAr: jsonText(json['name_ar']),
        job: jsonTextOrNull(json['job']),
        education: jsonTextOrNull(json['education']),
        phone: jsonTextOrNull(json['phone']),
      );

  /// [json] when it's one (the API sends null for none).
  static ChildParentModel? maybeFromJson(Object? json) => switch (json) {
    final Map<String, dynamic> json => ChildParentModel.fromJson(json),
    _ => null,
  };
}
