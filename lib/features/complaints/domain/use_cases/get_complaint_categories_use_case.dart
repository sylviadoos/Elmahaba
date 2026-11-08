import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_category_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/repos/complaints_repo.dart';

/// The complaint categories: `final result = await getCategories();`
@lazySingleton
class GetComplaintCategoriesUseCase {
  GetComplaintCategoriesUseCase(this._repo);

  final ComplaintsRepo _repo;

  Future<Result<List<ComplaintCategoryEntity>>> call() => _repo.getCategories();
}
