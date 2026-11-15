import 'package:dio/dio.dart';

import 'package:al_mahhaba_school/core/network/multipart_files.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/new_complaint_entity.dart';

/// [NewComplaintEntity] as sent to `POST v1/parent/complaints`.
class NewComplaintModel extends NewComplaintEntity {
  const NewComplaintModel({
    required super.categoryId,
    super.studentId,
    required super.description,
    super.attachments,
    required super.clientUuid,
  });

  factory NewComplaintModel.fromEntity(NewComplaintEntity entity) =>
      NewComplaintModel(
        categoryId: entity.categoryId,
        studentId: entity.studentId,
        description: entity.description,
        attachments: entity.attachments,
        clientUuid: entity.clientUuid,
      );

  /// category_id, student_id (left out for a general one), description,
  /// client_uuid and one `attachments[]` per file.
  Future<FormData> toFormData() async {
    final studentId = this.studentId;

    return FormData()
      ..fields.addAll([
        MapEntry('category_id', '$categoryId'),
        if (studentId != null) MapEntry('student_id', '$studentId'),
        MapEntry('description', description),
        MapEntry('client_uuid', clientUuid),
      ])
      ..files.addAll(await multipartFiles('attachments[]', attachments));
  }
}
