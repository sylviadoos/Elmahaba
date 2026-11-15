import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_status_json.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_status.dart';

class ComplaintModel extends ComplaintEntity {
  const ComplaintModel({
    required super.id,
    required super.reference,
    required super.categoryEn,
    required super.categoryAr,
    required super.childName,
    required super.childNameAr,
    required super.status,
    required super.isOpen,
    required super.canReply,
    super.submittedAt,
    super.lastUpdate,
  });

  /// { "id": 12, "reference_number": "CMP-2026-00012",
  ///   "category": { "en": "Transport", "ar": "النقل" },
  ///   "child": { "id": 345, "name": "Omar Ahmed", "name_ar": "عمر أحمد" },
  ///   "status": "submitted", "is_open": true, "can_reply": false,
  ///   "submitted_at": "2026-11-03T09:15:00+02:00",
  ///   "last_update": "2026-11-03T09:15:00+02:00", … }
  ///
  /// A status this app doesn't know yet reads as under review while it's
  /// open, and as resolved once closed.
  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>? ?? const {};
    final child = json['child'] as Map<String, dynamic>? ?? const {};
    final isOpen = json['is_open'] as bool? ?? true;
    final status =
        complaintStatusFromJson(json['status']) ??
        (isOpen ? ComplaintStatus.underReview : ComplaintStatus.resolved);

    return ComplaintModel(
      id: json['id'] as int? ?? 0,
      reference: json['reference_number'] as String? ?? '',
      categoryEn: jsonText(category['en']),
      categoryAr: jsonText(category['ar']),
      childName: jsonText(child['name']),
      childNameAr: jsonText(child['name_ar']),
      status: status,
      isOpen: isOpen,
      // Missing: only while the school awaits the parent's answer.
      canReply:
          json['can_reply'] as bool? ??
          status == ComplaintStatus.awaitingParentResponse,
      submittedAt: DateTime.tryParse(
        json['submitted_at'] as String? ?? '',
      )?.toLocal(),
      lastUpdate: DateTime.tryParse(
        json['last_update'] as String? ?? '',
      )?.toLocal(),
    );
  }
}
