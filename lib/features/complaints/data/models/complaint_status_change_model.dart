import 'package:al_mahhaba_school/features/complaints/data/models/complaint_status_json.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_status_change_entity.dart';

class ComplaintStatusChangeModel extends ComplaintStatusChangeEntity {
  const ComplaintStatusChangeModel({required super.status, super.at});

  /// { "from": "submitted", "to": "under_review",
  ///   "at": "2026-11-03T12:40:00+02:00" }
  ///
  /// Null for a status this app doesn't know yet.
  static ComplaintStatusChangeModel? fromJson(Map<String, dynamic> json) {
    final status = complaintStatusFromJson(json['to']);
    if (status == null) return null;
    return ComplaintStatusChangeModel(
      status: status,
      at: DateTime.tryParse(json['at'] as String? ?? '')?.toLocal(),
    );
  }
}
