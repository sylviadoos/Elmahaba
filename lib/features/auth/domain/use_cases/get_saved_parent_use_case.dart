import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/auth/domain/entities/parent_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/repos/auth_repo.dart';

/// The signed-in parent kept on the phone, or null:
/// `final parent = await getSavedParent();`
@lazySingleton
class GetSavedParentUseCase {
  GetSavedParentUseCase(this._repo);

  final AuthRepo _repo;

  Future<ParentEntity?> call() => _repo.getSavedParent();
}
