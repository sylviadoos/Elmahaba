import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/excuses/data/models/excuse_json.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_history_entity.dart';

class ExcuseHistoryModel extends ExcuseHistoryEntity {
  const ExcuseHistoryModel({
    required super.action,
    required super.by,
    super.text,
    super.at,
  });

  /// { "action": "submitted", "by": "parent", "text": null,
  ///   "at": "2026-11-04T10:15:00+00:00" }
  factory ExcuseHistoryModel.fromJson(Map<String, dynamic> json) {
    final text = jsonText(json['text']);
    return ExcuseHistoryModel(
      action: json['action'] as String? ?? '',
      by: json['by'] as String? ?? '',
      text: text.isEmpty ? null : text,
      at: excuseDateFromJson(json['at']),
    );
  }
}
