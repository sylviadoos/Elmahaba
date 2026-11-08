import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/profile/domain/entities/notification_preferences_entity.dart';
import 'package:al_mahhaba_school/features/profile/domain/repos/profile_repo.dart';

/// Which notifications ring the phone:
/// `final result = await getNotificationPreferences();`
@lazySingleton
class GetNotificationPreferencesUseCase {
  GetNotificationPreferencesUseCase(this._repo);

  final ProfileRepo _repo;

  Future<Result<NotificationPreferencesEntity>> call() =>
      _repo.getNotificationPreferences();
}
