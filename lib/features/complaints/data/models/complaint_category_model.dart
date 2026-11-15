import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_category_entity.dart';

class ComplaintCategoryModel extends ComplaintCategoryEntity {
  const ComplaintCategoryModel({
    required super.id,
    required super.nameEn,
    required super.nameAr,
  });

  /// { "id": 2, "name_en": "academic", "name_ar": "اكاديمى" }
  factory ComplaintCategoryModel.fromJson(Map<String, dynamic> json) =>
      ComplaintCategoryModel(
        id: json['id'] as int? ?? 0,
        nameEn: jsonText(json['name_en']),
        nameAr: jsonText(json['name_ar']),
      );
}
