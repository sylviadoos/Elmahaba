import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_attachment_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/repos/complaints_repo.dart';

/// Saves a complaint's file on the phone, to open it:
/// `final result = await downloadAttachment(complaint.id, attachment);`
@lazySingleton
class DownloadComplaintAttachmentUseCase {
  DownloadComplaintAttachmentUseCase(this._repo);

  final ComplaintsRepo _repo;

  Future<Result<String>> call(
    int complaintId,
    ComplaintAttachmentEntity attachment,
  ) => _repo.downloadAttachment(complaintId, attachment);
}
