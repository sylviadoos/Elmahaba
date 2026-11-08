import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/auth_session_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/complete_register_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/repos/auth_repo.dart';

/// Creates the parent's account once the number is verified:
/// `final result = await completeRegister(request);`
@lazySingleton
class CompleteRegisterUseCase {
  CompleteRegisterUseCase(this._repo);

  final AuthRepo _repo;

  Future<Result<AuthSessionEntity>> call(
    CompleteRegisterRequestEntity request,
  ) => _repo.completeRegistration(request);
}
