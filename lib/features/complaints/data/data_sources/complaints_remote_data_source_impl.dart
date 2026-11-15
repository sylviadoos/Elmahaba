import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/complaints/data/data_sources/complaints_remote_data_source.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_category_model.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_details_model.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_model.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_reply_model.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaints_page_model.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/new_complaint_model.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_attachment_entity.dart';

@LazySingleton(as: ComplaintsRemoteDataSource)
class ComplaintsRemoteDataSourceImpl implements ComplaintsRemoteDataSource {
  ComplaintsRemoteDataSourceImpl(@Named(ApiNames.school) this._api);

  final ApiService _api;

  static const int _perPage = 20;

  @override
  Future<List<ComplaintCategoryModel>> getCategories() async {
    // { "status": "success", "data": [ { "id": 1, "name_en": "General",
    //   "name_ar": "عام" } ] }
    final json =
        await _api.get(ApiEndpoints.complaintCategories)
            as Map<String, dynamic>;
    return [
      for (final category in jsonObjects(json[ApiKeys.data]))
        ComplaintCategoryModel.fromJson(category),
    ];
  }

  @override
  Future<ComplaintsPageModel> getComplaints({required int page}) async {
    final json =
        await _api.get(
              ApiEndpoints.complaints,
              queryParameters: {'page': page, 'per_page': _perPage},
            )
            as Map<String, dynamic>;
    return ComplaintsPageModel.fromJson(json);
  }

  @override
  Future<ComplaintModel> sendComplaint(
    NewComplaintModel complaint, {
    UploadProgressCallback? onProgress,
  }) async {
    // { "status": "success", "code": "complaint_submitted",
    //   "data": { …complaint…, "description": "…", "messages": […],
    //   "status_history": […] } }
    final json =
        await _api.upload(
              ApiEndpoints.complaints,
              formData: await complaint.toFormData(),
              onSendProgress: onProgress,
            )
            as Map<String, dynamic>;
    return ComplaintModel.fromJson(json[ApiKeys.data] as Map<String, dynamic>);
  }

  @override
  Future<ComplaintDetailsModel> getComplaint(int complaintId) async {
    // { "status": "success", "data": { …complaint…, "description": "…",
    //   "messages": […], "status_history": […] } }
    final json =
        await _api.get(ApiEndpoints.complaint(complaintId))
            as Map<String, dynamic>;
    return ComplaintDetailsModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }

  @override
  Future<ComplaintDetailsModel> sendReply(
    int complaintId,
    ComplaintReplyModel reply, {
    UploadProgressCallback? onProgress,
  }) async {
    // { "status": "success", "code": "complaint_reply_sent",
    //   "data": { …the complaint, with the reply… } }
    final json =
        await _api.upload(
              ApiEndpoints.complaintReplies(complaintId),
              formData: await reply.toFormData(),
              onSendProgress: onProgress,
            )
            as Map<String, dynamic>;
    return ComplaintDetailsModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }

  @override
  Future<String> downloadAttachment(
    int complaintId,
    ComplaintAttachmentEntity attachment,
  ) async {
    final folder = await getTemporaryDirectory();
    // The server's name, minus anything that would leave the folder.
    final name = attachment.fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final file = File(
      '${folder.path}/complaint_attachments/${attachment.id}_$name',
    );
    if (!await file.exists()) {
      await file.parent.create(recursive: true);
      await _api.download(
        ApiEndpoints.complaintAttachment(complaintId, attachment.id),
        file.path,
      );
    }
    return file.path;
  }
}
