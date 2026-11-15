import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/reset_password_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/repos/auth_repo.dart';

/// Sets a new password once the number is verified:
/// `final result = await resetPassword(request);`
@lazySingleton
class ResetPasswordUseCase {
  ResetPasswordUseCase(this._repo);

  final AuthRepo _repo;

  Future<Result<void>> call(ResetPasswordRequestEntity request) =>
      _repo.resetPassword(request);
}
