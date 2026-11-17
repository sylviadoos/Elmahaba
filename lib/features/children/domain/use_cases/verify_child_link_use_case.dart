import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_proof_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/repos/children_repo.dart';

/// Links a child once the school's number for them is proved — by the code
/// the school texted, or by Firebase:
/// `final result = await verifyChildLink(token: …, proof: SchoolCodeProof('123456'));`
@lazySingleton
class VerifyChildLinkUseCase {
  VerifyChildLinkUseCase(this._repo);

  final ChildrenRepo _repo;

  Future<Result<ChildEntity>> call({
    required String token,
    required PhoneProofEntity proof,
  }) => _repo.verifyChildLink(token: token, proof: proof);
}
