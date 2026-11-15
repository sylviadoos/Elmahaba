import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_verification_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/repos/children_repo.dart';

/// Texts the code for linking a child again:
/// `final result = await resendChildLinkCode(verification.token);`
@lazySingleton
class ResendChildLinkCodeUseCase {
  ResendChildLinkCodeUseCase(this._repo);

  final ChildrenRepo _repo;

  Future<Result<LinkVerificationEntity>> call(String token) =>
      _repo.resendChildLinkCode(token);
}
