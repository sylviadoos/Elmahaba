import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/auth/domain/repos/auth_repo.dart';

/// Signs the parent out on this phone: `await logout();`
@lazySingleton
class LogoutUseCase {
  LogoutUseCase(this._repo);

  final AuthRepo _repo;

  Future<Result<void>> call() => _repo.logout();
}
