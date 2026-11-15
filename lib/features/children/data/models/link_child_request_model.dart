import 'package:al_mahhaba_school/features/children/domain/entities/link_child_request_entity.dart';

/// [LinkChildRequestEntity] as sent to `POST v1/parent/children/link`.
class LinkChildRequestModel extends LinkChildRequestEntity {
  const LinkChildRequestModel({
    required super.nationalId,
    super.relationship,
    super.note,
  });

  factory LinkChildRequestModel.fromEntity(LinkChildRequestEntity entity) =>
      LinkChildRequestModel(
        nationalId: entity.nationalId,
        relationship: entity.relationship,
        note: entity.note,
      );

  /// Optional fields are left out when empty.
  Map<String, dynamic> toJson() {
    final relationship = this.relationship;
    final note = this.note?.trim();
    return {
      'national_id': nationalId,
      if (relationship != null && relationship.isNotEmpty)
        'relationship': relationship,
      if (note != null && note.isNotEmpty) 'note': note,
    };
  }
}
