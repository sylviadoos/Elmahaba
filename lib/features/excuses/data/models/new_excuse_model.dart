import 'package:dio/dio.dart';

import 'package:al_mahhaba_school/core/network/multipart_files.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/new_excuse_entity.dart';

/// [NewExcuseEntity] as sent to `POST …/children/{id}/excuses`.
class NewExcuseModel extends NewExcuseEntity {
  const NewExcuseModel({
    required super.attendanceId,
    super.note,
    required super.documents,
  });

  factory NewExcuseModel.fromEntity(NewExcuseEntity entity) => NewExcuseModel(
    attendanceId: entity.attendanceId,
    note: entity.note,
    documents: entity.documents,
  );

  /// attendance_id, note (left out when empty) and one `documents[]` per
  /// file.
  Future<FormData> toFormData() async => FormData()
    ..fields.addAll([
      MapEntry('attendance_id', '$attendanceId'),
      if (note.isNotEmpty) MapEntry('note', note),
    ])
    ..files.addAll(await multipartFiles('documents[]', documents));
}
