import 'package:al_mahhaba_school/features/app_status/data/models/app_status_model.dart';

/// Talks to the school API's app status endpoint. Throws an `AppException`
/// on failure.
abstract interface class AppStatusRemoteDataSource {
  Future<AppStatusModel> getAppStatus();
}
