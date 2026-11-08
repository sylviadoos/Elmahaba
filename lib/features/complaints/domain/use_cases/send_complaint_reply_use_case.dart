import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_details_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_reply_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/repos/complaints_repo.dart';

/// Replies on a complaint, [onProgress] following its files' upload:
/// `final result = await sendReply(complaint.id, reply);`
@lazySingleton
class SendComplaintReplyUseCase {
  SendComplaintReplyUseCase(this._repo);

  final ComplaintsRepo _repo;

  Future<Result<ComplaintDetailsEntity>> call(
    int complaintId,
    ComplaintReplyEntity reply, {
    UploadProgressCallback? onProgress,
  }) => _repo.sendReply(complaintId, reply, onProgress: onProgress);
}
