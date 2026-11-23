import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/children/domain/repos/children_repo.dart';

/// The child the parent last picked, kept across launches, by `studentId`;
/// null when none was: `final studentId = await getSelectedChild();`
@lazySingleton
class GetSelectedChildUseCase {
  GetSelectedChildUseCase(this._repo);

  final ChildrenRepo _repo;

  Future<int?> call() => _repo.getSelectedChildId();
}
