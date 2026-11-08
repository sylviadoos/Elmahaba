import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaints_page_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/repos/complaints_repo.dart';

/// A page of the parent's complaints:
/// `final result = await getComplaints(page: 1);`
@lazySingleton
class GetComplaintsUseCase {
  GetComplaintsUseCase(this._repo);

  final ComplaintsRepo _repo;

  Future<Result<ComplaintsPageEntity>> call({required int page}) =>
      _repo.getComplaints(page: page);
}
