import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_attachment_entity.dart';

class ComplaintAttachmentModel extends ComplaintAttachmentEntity {
  const ComplaintAttachmentModel({
    required super.id,
    required super.fileName,
    required super.mimeType,
    required super.size,
    required super.isAvailable,
  });

  /// { "id": 88, "file_name": "bus-photo.jpg", "mime": "image/jpeg",
  ///   "size": 245781, "status": "available" }
  factory ComplaintAttachmentModel.fromJson(Map<String, dynamic> json) =>
      ComplaintAttachmentModel(
        id: json['id'] as int? ?? 0,
        fileName: json['file_name'] as String? ?? '',
        mimeType: json['mime'] as String? ?? '',
        size: json['size'] as int? ?? 0,
        isAvailable: json['status'] == 'available',
      );
}
