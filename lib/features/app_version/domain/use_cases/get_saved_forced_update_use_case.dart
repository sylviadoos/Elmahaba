import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/app_version/domain/entities/app_version_entity.dart';
import 'package:al_mahhaba_school/features/app_version/domain/repos/app_version_repo.dart';

/// The forced update last seen for the version installed now, shown at once
/// as the app opens, before (or without) the school answering:
/// `final forced = await getSavedForcedUpdate();`
@lazySingleton
class GetSavedForcedUpdateUseCase {
  GetSavedForcedUpdateUseCase(this._repo);

  final AppVersionRepo _repo;

  Future<AppVersionEntity?> call() => _repo.savedForcedUpdate();
}
