import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/children/domain/repos/children_repo.dart';

/// Keeps the child picked for the next launch:
/// `await saveSelectedChild(studentId);`
@lazySingleton
class SaveSelectedChildUseCase {
  SaveSelectedChildUseCase(this._repo);

  final ChildrenRepo _repo;

  Future<void> call(int studentId) => _repo.saveSelectedChildId(studentId);
}
