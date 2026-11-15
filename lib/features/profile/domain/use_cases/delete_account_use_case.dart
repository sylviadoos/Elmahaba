import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/profile/domain/repos/profile_repo.dart';

/// Deletes the parent's account: `await deleteAccount();` — then log out.
@lazySingleton
class DeleteAccountUseCase {
  DeleteAccountUseCase(this._repo);

  final ProfileRepo _repo;

  Future<Result<void>> call() => _repo.deleteAccount();
}
