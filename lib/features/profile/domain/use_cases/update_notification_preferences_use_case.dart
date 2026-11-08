import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/profile/domain/entities/notification_preferences_entity.dart';
import 'package:al_mahhaba_school/features/profile/domain/repos/profile_repo.dart';

/// Saves what changes in which notifications ring the phone; all of them
/// come back as saved:
/// `await updateNotificationPreferences(categories: {'fees': false});`
@lazySingleton
class UpdateNotificationPreferencesUseCase {
  UpdateNotificationPreferencesUseCase(this._repo);

  final ProfileRepo _repo;

  Future<Result<NotificationPreferencesEntity>> call({
    bool? pushEnabled,
    Map<String, bool> categories = const {},
  }) => _repo.updateNotificationPreferences(
    pushEnabled: pushEnabled,
    categories: categories,
  );
}
