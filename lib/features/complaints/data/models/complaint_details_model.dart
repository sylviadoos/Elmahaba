import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_message_model.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_model.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_status_change_model.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_details_entity.dart';

/// The `data` of `GET v1/parent/complaints/{id}` (and of a reply).
class ComplaintDetailsModel extends ComplaintDetailsEntity {
  const ComplaintDetailsModel({
    required super.complaint,
    required super.description,
    required super.messages,
    required super.statusHistory,
  });

  /// { …complaint…, "description": "The school bus arrived…",
  ///   "messages": [ …message… ], "status_history": [ …change… ] }
  factory ComplaintDetailsModel.fromJson(Map<String, dynamic> json) =>
      ComplaintDetailsModel(
        complaint: ComplaintModel.fromJson(json),
        // As written: line breaks kept.
        description: (json['description'] as String? ?? '').trim(),
        messages: [
          for (final message in jsonObjects(json['messages']))
            ComplaintMessageModel.fromJson(message),
        ],
        statusHistory: [
          for (final change in jsonObjects(json['status_history']))
            ?ComplaintStatusChangeModel.fromJson(change),
        ],
      );
}
