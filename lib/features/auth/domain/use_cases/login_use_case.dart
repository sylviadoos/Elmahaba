import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/auth_session_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/login_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/repos/auth_repo.dart';

/// Signs a parent in: `final result = await login(request);`
@lazySingleton
class LoginUseCase {
  LoginUseCase(this._repo);

  final AuthRepo _repo;

  Future<Result<AuthSessionEntity>> call(LoginRequestEntity request) =>
      _repo.login(request);
}
