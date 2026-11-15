import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/excuses/data/models/excuse_document_model.dart';
import 'package:al_mahhaba_school/features/excuses/data/models/excuse_history_model.dart';
import 'package:al_mahhaba_school/features/excuses/data/models/excuse_json.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_details_entity.dart';

class ExcuseDetailsModel extends ExcuseDetailsEntity {
  const ExcuseDetailsModel({
    required super.id,
    required super.attendanceId,
    super.absenceDate,
    required super.status,
    super.note,
    required super.submittedByYou,
    super.submittedAt,
    super.decidedAt,
    super.rejectionReason,
    super.informationRequest,
    required super.canAddDocuments,
    required super.maxDocuments,
    super.documents,
    super.history,
  });

  /// { "id": 42, "student": {…}, "attendance_id": 9120,
  ///   "absence_date": "2026-11-04", "attendance_status": "absent",
  ///   "status": "submitted", "is_active": true, "note": "…",
  ///   "submitted_by": "you", "relationship": "father",
  ///   "submitted_at": "…", "decided_at": null, "rejection_reason": null,
  ///   "information_request": null, "can_add_documents": false,
  ///   "max_documents": 5, "documents": [ …document… ],
  ///   "history": [ …step… ] }
  factory ExcuseDetailsModel.fromJson(Map<String, dynamic> json) {
    String? text(String key) {
      final value = jsonText(json[key]);
      return value.isEmpty ? null : value;
    }

    return ExcuseDetailsModel(
      id: json['id'] as int? ?? 0,
      attendanceId: json['attendance_id'] as int? ?? 0,
      absenceDate: excuseDateFromJson(json['absence_date']),
      status: excuseStatusFromJson(json['status']),
      note: text('note'),
      // "you", or "other_parent".
      submittedByYou: json['submitted_by'] != 'other_parent',
      submittedAt: excuseDateFromJson(json['submitted_at']),
      decidedAt: excuseDateFromJson(json['decided_at']),
      rejectionReason: text('rejection_reason'),
      informationRequest: text('information_request'),
      canAddDocuments: json['can_add_documents'] as bool? ?? false,
      maxDocuments: json['max_documents'] as int? ?? 5,
      documents: [
        for (final document in jsonObjects(json['documents']))
          ExcuseDocumentModel.fromJson(document),
      ],
      history: [
        for (final step in jsonObjects(json['history']))
          ExcuseHistoryModel.fromJson(step),
      ],
    );
  }
}
