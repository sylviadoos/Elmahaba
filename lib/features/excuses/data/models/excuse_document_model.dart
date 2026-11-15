import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_document_entity.dart';

class ExcuseDocumentModel extends ExcuseDocumentEntity {
  const ExcuseDocumentModel({
    required super.id,
    required super.fileName,
    required super.mimeType,
    required super.size,
    required super.isAvailable,
  });

  /// { "id": 310, "file_name": "medical-report.pdf",
  ///   "mime": "application/pdf", "size": 183422, "status": "available" }
  factory ExcuseDocumentModel.fromJson(Map<String, dynamic> json) =>
      ExcuseDocumentModel(
        id: json['id'] as int? ?? 0,
        fileName: json['file_name'] as String? ?? '',
        mimeType: json['mime'] as String? ?? '',
        size: json['size'] as int? ?? 0,
        isAvailable: json['status'] == 'available',
      );
}
