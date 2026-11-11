import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/app_status/domain/entities/app_status_entity.dart';
import 'package:al_mahhaba_school/features/app_status/domain/repos/app_status_repo.dart';

/// Asks the school whether parents can log in now:
/// `final result = await getAppStatus();`
@lazySingleton
class GetAppStatusUseCase {
  GetAppStatusUseCase(this._repo);

  final AppStatusRepo _repo;

  Future<Result<AppStatusEntity>> call() => _repo.getAppStatus();
}
