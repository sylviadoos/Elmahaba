import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/complaints/data/data_sources/complaints_remote_data_source.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_reply_model.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/new_complaint_model.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_attachment_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_category_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_details_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_reply_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaints_page_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/new_complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/repos/complaints_repo.dart';

@LazySingleton(as: ComplaintsRepo)
class ComplaintsRepoImpl implements ComplaintsRepo {
  ComplaintsRepoImpl(this._remoteDataSource);

  final ComplaintsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<ComplaintCategoryEntity>>> getCategories() =>
      Result.guard(_remoteDataSource.getCategories);

  @override
  Future<Result<ComplaintsPageEntity>> getComplaints({required int page}) =>
      Result.guard(() => _remoteDataSource.getComplaints(page: page));

  @override
  Future<Result<ComplaintEntity>> sendComplaint(
    NewComplaintEntity complaint, {
    UploadProgressCallback? onProgress,
  }) => Result.guard(
    () => _remoteDataSource.sendComplaint(
      NewComplaintModel.fromEntity(complaint),
      onProgress: onProgress,
    ),
  );

  @override
  Future<Result<ComplaintDetailsEntity>> getComplaint(int complaintId) =>
      Result.guard(() => _remoteDataSource.getComplaint(complaintId));

  @override
  Future<Result<ComplaintDetailsEntity>> sendReply(
    int complaintId,
    ComplaintReplyEntity reply, {
    UploadProgressCallback? onProgress,
  }) => Result.guard(
    () => _remoteDataSource.sendReply(
      complaintId,
      ComplaintReplyModel.fromEntity(reply),
      onProgress: onProgress,
    ),
  );

  @override
  Future<Result<String>> downloadAttachment(
    int complaintId,
    ComplaintAttachmentEntity attachment,
  ) => Result.guard(
    () => _remoteDataSource.downloadAttachment(complaintId, attachment),
  );
}
