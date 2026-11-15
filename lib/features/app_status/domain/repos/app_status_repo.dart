import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/app_status/domain/entities/app_status_entity.dart';

/// Never throws — errors come back as a `Failure`.
abstract interface class AppStatusRepo {
  Future<Result<AppStatusEntity>> getAppStatus();
}
