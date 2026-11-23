import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/app_version/domain/entities/app_version_entity.dart';
import 'package:al_mahhaba_school/features/app_version/domain/repos/app_version_repo.dart';

/// Whether the version installed here must, or can, be updated:
/// `final result = await checkAppVersion();`
@lazySingleton
class CheckAppVersionUseCase {
  CheckAppVersionUseCase(this._repo);

  final AppVersionRepo _repo;

  Future<Result<AppVersionEntity>> call() => _repo.check();
}
