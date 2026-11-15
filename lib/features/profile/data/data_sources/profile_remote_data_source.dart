import 'package:al_mahhaba_school/features/profile/data/models/notification_preferences_model.dart';
import 'package:al_mahhaba_school/features/profile/data/models/profile_model.dart';
import 'package:al_mahhaba_school/features/profile/data/models/update_language_request_model.dart';
import 'package:al_mahhaba_school/features/profile/data/models/update_notification_preferences_request_model.dart';

/// Talks to the school system's account endpoints (signed in). Throws an
/// `AppException` on failure.
abstract interface class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();

  Future<void> updateLanguage(UpdateLanguageRequestModel request);

  /// Deletes the account; its token stops working.
  Future<void> deleteAccount();

  /// Whether notifications ring the phone, and which kinds.
  Future<NotificationPreferencesModel> getNotificationPreferences();

  /// Changes what's in [request]; all of them come back. Fails with a 422
  /// `ServerException` for a kind the school doesn't have.
  Future<NotificationPreferencesModel> updateNotificationPreferences(
    UpdateNotificationPreferencesRequestModel request,
  );
}
