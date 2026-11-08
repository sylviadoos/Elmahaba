import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_details_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/repos/children_repo.dart';

/// One child in full: `final result = await getChildDetails(childId);`
@lazySingleton
class GetChildDetailsUseCase {
  GetChildDetailsUseCase(this._repo);

  final ChildrenRepo _repo;

  Future<Result<ChildDetailsEntity>> call(int childId) =>
      _repo.getChildDetails(childId);
}
