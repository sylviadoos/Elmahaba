import 'package:al_mahhaba_school/features/excuses/data/models/excuse_json.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_summary_entity.dart';

class ExcuseSummaryModel extends ExcuseSummaryEntity {
  const ExcuseSummaryModel({
    required super.id,
    required super.status,
    super.submittedAt,
  });

  /// { "id": 41, "status": "info_required",
  ///   "submitted_at": "2026-11-02T08:10:00+00:00" }
  factory ExcuseSummaryModel.fromJson(Map<String, dynamic> json) =>
      ExcuseSummaryModel(
        id: json['id'] as int? ?? 0,
        status: excuseStatusFromJson(json['status']),
        submittedAt: excuseDateFromJson(json['submitted_at']),
      );
}
