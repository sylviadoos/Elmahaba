import 'package:dio/dio.dart';

import 'package:al_mahhaba_school/core/network/multipart_files.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_reply_entity.dart';

/// [ComplaintReplyEntity] as sent to `POST v1/parent/complaints/{id}/replies`.
class ComplaintReplyModel extends ComplaintReplyEntity {
  const ComplaintReplyModel({
    required super.text,
    super.attachments,
    required super.clientUuid,
  });

  factory ComplaintReplyModel.fromEntity(ComplaintReplyEntity entity) =>
      ComplaintReplyModel(
        text: entity.text,
        attachments: entity.attachments,
        clientUuid: entity.clientUuid,
      );

  /// text (left out when empty), client_uuid and one `attachments[]` per
  /// file.
  Future<FormData> toFormData() async => FormData()
    ..fields.addAll([
      if (text.isNotEmpty) MapEntry('text', text),
      MapEntry('client_uuid', clientUuid),
    ])
    ..files.addAll(await multipartFiles('attachments[]', attachments));
}
