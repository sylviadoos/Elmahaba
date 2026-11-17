import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/repos/children_repo.dart';

/// Has Firebase send the code for linking a child to the school's number
/// for them:
/// `final result = await sendChildLinkCode(verification.phone!, resendToken: last);`
@lazySingleton
class SendChildLinkCodeUseCase {
  SendChildLinkCodeUseCase(this._repo);

  final ChildrenRepo _repo;

  Future<Result<PhoneVerificationEntity>> call(
    String phone, {
    int? resendToken,
  }) => _repo.sendChildLinkCode(phone, resendToken: resendToken);
}
