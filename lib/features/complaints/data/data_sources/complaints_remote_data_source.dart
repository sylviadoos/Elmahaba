import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_category_model.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_details_model.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_model.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_reply_model.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaints_page_model.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/new_complaint_model.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_attachment_entity.dart';

/// Talks to the school system's complaints endpoints (signed in). Throws an
/// `AppException` on failure.
abstract interface class ComplaintsRemoteDataSource {
  Future<List<ComplaintCategoryModel>> getCategories();

  /// One [page] (from 1) of the parent's complaints, newest first.
  Future<ComplaintsPageModel> getComplaints({required int page});

  /// Fails with a 422 `ServerException`: `validation_failed` (with
  /// `fieldErrors`), `child_not_available`, `read_only_child`,
  /// `complaint_requires_active_child`, `category_not_available`,
  /// `file_type_or_size_not_allowed`, `too_many_attachments` or
  /// `file_rejected` (naming the file). [onProgress] follows the upload.
  Future<ComplaintModel> sendComplaint(
    NewComplaintModel complaint, {
    UploadProgressCallback? onProgress,
  });

  /// Fails with a 404 `ServerException` (`not_found`) for one that isn't
  /// the parent's.
  Future<ComplaintDetailsModel> getComplaint(int complaintId);

  /// Fails with a 422 `ServerException`: `text_or_attachment_required`,
  /// `complaint_closed` or `file_rejected` (naming the file). [onProgress]
  /// follows the upload.
  Future<ComplaintDetailsModel> sendReply(
    int complaintId,
    ComplaintReplyModel reply, {
    UploadProgressCallback? onProgress,
  });

  /// Saves the file in the app's temporary folder (once: a saved one is
  /// reused) and returns its path.
  Future<String> downloadAttachment(
    int complaintId,
    ComplaintAttachmentEntity attachment,
  );
}
