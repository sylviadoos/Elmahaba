import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/change_password_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/repos/auth_repo.dart';

/// Changes the signed-in parent's password:
/// `final result = await changePassword(request);`
@lazySingleton
class ChangePasswordUseCase {
  ChangePasswordUseCase(this._repo);

  final AuthRepo _repo;

  Future<Result<void>> call(ChangePasswordRequestEntity request) =>
      _repo.changePassword(request);
}
