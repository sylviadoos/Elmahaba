import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_details_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/repos/complaints_repo.dart';

/// A complaint with its thread:
/// `final result = await getComplaintDetails(complaint.id);`
@lazySingleton
class GetComplaintDetailsUseCase {
  GetComplaintDetailsUseCase(this._repo);

  final ComplaintsRepo _repo;

  Future<Result<ComplaintDetailsEntity>> call(int complaintId) =>
      _repo.getComplaint(complaintId);
}
