import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/repos/children_repo.dart';

/// The children saved on the phone, without calling the API:
/// `final children = await getSavedChildren();`
@lazySingleton
class GetSavedChildrenUseCase {
  GetSavedChildrenUseCase(this._repo);

  final ChildrenRepo _repo;

  Future<List<ChildEntity>> call() => _repo.getSavedChildren();
}
