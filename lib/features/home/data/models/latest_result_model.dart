import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_result_entity.dart';

class LatestResultModel extends LatestResultEntity {
  const LatestResultModel({
    required super.id,
    required super.title,
    required super.academicYear,
    required super.resultType,
    super.publishedAt,
    super.isRead,
    super.chatKey,
  });

  /// { "id": 280, "title": "…", "academic_year": "2026-2027",
  ///   "result_type": "value and color",
  ///   "published_at": "2026-11-04T17:48:00+00:00", "publication_id": 46,
  ///   "chat_key": "event:34", "is_read": true } — the one under
  /// `results.latest` may carry neither `is_read` nor `chat_key`; the ones
  /// in `results.items` do.
  factory LatestResultModel.fromJson(Map<String, dynamic> json) =>
      LatestResultModel(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        academicYear: json['academic_year'] as String? ?? '',
        resultType: json['result_type'] as String? ?? '',
        // "2026-06-03T11:55:34+00:00", in UTC.
        publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
        isRead: json['is_read'] as bool? ?? true,
        chatKey: jsonTextOrNull(json['chat_key']),
      );
}
