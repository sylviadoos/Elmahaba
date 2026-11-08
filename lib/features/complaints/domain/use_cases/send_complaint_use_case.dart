import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/new_complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/repos/complaints_repo.dart';

/// Sends a complaint, [onProgress] following its files' upload:
/// `final result = await sendComplaint(complaint);`
@lazySingleton
class SendComplaintUseCase {
  SendComplaintUseCase(this._repo);

  final ComplaintsRepo _repo;

  Future<Result<ComplaintEntity>> call(
    NewComplaintEntity complaint, {
    UploadProgressCallback? onProgress,
  }) => _repo.sendComplaint(complaint, onProgress: onProgress);
}
