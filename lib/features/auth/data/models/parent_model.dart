import 'package:al_mahhaba_school/features/auth/domain/entities/parent_entity.dart';

class ParentModel extends ParentEntity {
  const ParentModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.language,
    super.fullPhone,
  });

  /// The API's, or a saved one ([toJson]), which may have "full_phone".
  factory ParentModel.fromJson(Map<String, dynamic> json) => ParentModel(
    id: json['id'] as int,
    name: json['name'] as String,
    phone: json['phone'] as String,
    language: json['language'] as String,
    fullPhone: json['full_phone'] as String?,
  );

  factory ParentModel.fromEntity(ParentEntity entity) => switch (entity) {
    final ParentModel model => model,
    _ => ParentModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      language: entity.language,
      fullPhone: entity.fullPhone,
    ),
  };

  /// The same, with its [fullPhone].
  ParentModel withFullPhone(String fullPhone) => ParentModel(
    id: id,
    name: name,
    phone: phone,
    language: language,
    fullPhone: fullPhone,
  );

  /// The same shape as the API's, so a saved parent reads back with
  /// [ParentModel.fromJson].
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'language': language,
    if (fullPhone != null) 'full_phone': fullPhone,
  };
}
