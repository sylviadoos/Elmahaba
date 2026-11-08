import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/repos/auth_repo.dart';

/// Sends the SMS code that verifies a mobile:
/// `final result = await sendOtp(phone, resendToken: lastToken);`
@lazySingleton
class SendOtpUseCase {
  SendOtpUseCase(this._repo);

  final AuthRepo _repo;

  Future<Result<PhoneVerificationEntity>> call(
    String phone, {
    int? resendToken,
  }) => _repo.sendOtp(phone, resendToken: resendToken);
}
