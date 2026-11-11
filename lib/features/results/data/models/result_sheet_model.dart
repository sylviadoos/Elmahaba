import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_sheet_entity.dart';

class ResultSheetModel extends ResultSheetEntity {
  const ResultSheetModel({
    required super.id,
    required super.title,
    required super.template,
    required super.month,
    required super.display,
    required super.academicYear,
    super.publishedAt,
  });

  /// { "id": 341, "publication_id": 61, "title": "نتيجة شهر نوفمبر",
  ///   "template": "monthly", "layout": "monthly", "month": "November",
  ///   "display": "value and color", "academic_year": "2026-2027",
  ///   "published_at": "2026-12-05T10:00:00+00:00" } — with an `id`.
  factory ResultSheetModel.fromJson(Map<String, dynamic> json) =>
      ResultSheetModel(
        id: json['id'] as int,
        title: jsonText(json['title']),
        template: jsonText(json['template']),
        month: jsonText(json['month']),
        display: jsonText(json['display']),
        academicYear: jsonText(json['academic_year']),
        publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
      );
}
