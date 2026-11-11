import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_attachment_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_category_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_details_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_reply_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaints_page_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/new_complaint_entity.dart';

/// Never throws — errors come back as a `Failure`.
abstract interface class ComplaintsRepo {
  /// The kinds of complaint the school takes now.
  Future<Result<List<ComplaintCategoryEntity>>> getCategories();

  /// One [page] (from 1) of the parent's complaints, newest first.
  Future<Result<ComplaintsPageEntity>> getComplaints({required int page});

  /// Sends [complaint]; the result is it as the school filed it.
  /// [onProgress] follows the upload.
  Future<Result<ComplaintEntity>> sendComplaint(
    NewComplaintEntity complaint, {
    UploadProgressCallback? onProgress,
  });

  /// The complaint with this id, with its thread.
  Future<Result<ComplaintDetailsEntity>> getComplaint(int complaintId);

  /// Adds [reply] to the complaint's thread; the result is the complaint
  /// with it. [onProgress] follows the upload.
  Future<Result<ComplaintDetailsEntity>> sendReply(
    int complaintId,
    ComplaintReplyEntity reply, {
    UploadProgressCallback? onProgress,
  });

  /// Whether the school has changed a complaint since the parent last had
  /// their complaints on screen — the dot on the Complaints button. The
  /// API counts no unread replies, so this asks for the first page and
  /// compares; a parent who hasn't opened their complaints on this phone
  /// yet has anything there to read. Their own changes ([sendComplaint],
  /// [sendReply]) don't count, only the school's after them.
  Future<Result<bool>> hasNewComplaintUpdates();

  /// Remembers that the parent has seen the complaints up to
  /// [updatedAt] — `ComplaintsPageEntity.newestUpdate` of what was shown.
  /// Null (none of them says when it changed) leaves it as it was.
  Future<void> markComplaintsSeen(DateTime? updatedAt);

  /// Saves [attachment] on the phone; the result is where.
  Future<Result<String>> downloadAttachment(
    int complaintId,
    ComplaintAttachmentEntity attachment,
  );
}
