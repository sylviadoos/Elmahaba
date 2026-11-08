import 'package:al_mahhaba_school/features/auth/domain/entities/parent_entity.dart';

class ParentModel extends ParentEntity {
  const ParentModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.language,
  });

  factory ParentModel.fromJson(Map<String, dynamic> json) => ParentModel(
    id: json['id'] as int,
    name: json['name'] as String,
    phone: json['phone'] as String,
    language: json['language'] as String,
  );

  factory ParentModel.fromEntity(ParentEntity entity) => switch (entity) {
    final ParentModel model => model,
    _ => ParentModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      language: entity.language,
    ),
  };

  /// The same shape as the API's, so a saved parent reads back with
  /// [ParentModel.fromJson].
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'language': language,
  };
}
