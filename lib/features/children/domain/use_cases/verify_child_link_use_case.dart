import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/repos/children_repo.dart';

/// Links a child with the code the school texted to its phone:
/// `final result = await verifyChildLink(token: …, code: '123456');`
@lazySingleton
class VerifyChildLinkUseCase {
  VerifyChildLinkUseCase(this._repo);

  final ChildrenRepo _repo;

  Future<Result<ChildEntity>> call({
    required String token,
    required String code,
  }) => _repo.verifyChildLink(token: token, code: code);
}
