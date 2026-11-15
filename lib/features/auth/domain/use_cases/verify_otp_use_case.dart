import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/auth/domain/repos/auth_repo.dart';

/// Checks the typed SMS code and returns the Firebase ID token:
/// `final result = await verifyOtp(verificationId: id, smsCode: code);`
@lazySingleton
class VerifyOtpUseCase {
  VerifyOtpUseCase(this._repo);

  final AuthRepo _repo;

  Future<Result<String>> call({
    required String verificationId,
    required String smsCode,
  }) => _repo.verifyOtp(verificationId: verificationId, smsCode: smsCode);
}
