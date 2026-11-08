import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_request_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_result_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/repos/children_repo.dart';

/// Links a child to the parent's account by national ID:
/// `final result = await linkChild(request);`
@lazySingleton
class LinkChildUseCase {
  LinkChildUseCase(this._repo);

  final ChildrenRepo _repo;

  Future<Result<LinkChildResultEntity>> call(LinkChildRequestEntity request) =>
      _repo.linkChild(request);
}
