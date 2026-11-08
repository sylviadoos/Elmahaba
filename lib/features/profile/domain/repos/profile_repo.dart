import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/profile/domain/entities/notification_preferences_entity.dart';
import 'package:al_mahhaba_school/features/profile/domain/entities/profile_entity.dart';

/// Never throws — errors come back as a `Failure`.
abstract interface class ProfileRepo {
  Future<Result<ProfileEntity>> getProfile();

  /// Saves [language] ("en" or "ar") as the account's language.
  Future<Result<void>> updateLanguage(String language);

  /// Deletes the parent's account. The phone's own session isn't touched.
  Future<Result<void>> deleteAccount();

  Future<Result<NotificationPreferencesEntity>> getNotificationPreferences();

  /// Saves only what changes: the master switch ([pushEnabled]) and the
  /// [categories] given. All of them come back as saved.
  Future<Result<NotificationPreferencesEntity>> updateNotificationPreferences({
    bool? pushEnabled,
    Map<String, bool> categories = const {},
  });
}
