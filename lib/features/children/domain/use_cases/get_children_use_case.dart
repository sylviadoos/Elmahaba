import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/repos/children_repo.dart';

/// The children on the parent's account: `final result = await getChildren();`
@lazySingleton
class GetChildrenUseCase {
  GetChildrenUseCase(this._repo);

  final ChildrenRepo _repo;

  Future<Result<List<ChildEntity>>> call() => _repo.getChildren();
}
