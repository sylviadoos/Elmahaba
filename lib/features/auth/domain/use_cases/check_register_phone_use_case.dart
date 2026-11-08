import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/register_eligibility_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/register_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/repos/auth_repo.dart';

/// Checks a parent can sign up with this mobile, before the code is sent:
/// `final result = await checkRegisterPhone(request);`
@lazySingleton
class CheckRegisterPhoneUseCase {
  CheckRegisterPhoneUseCase(this._repo);

  final AuthRepo _repo;

  Future<Result<RegisterEligibilityEntity>> call(
    RegisterRequestEntity request,
  ) => _repo.checkPhone(request);
}
