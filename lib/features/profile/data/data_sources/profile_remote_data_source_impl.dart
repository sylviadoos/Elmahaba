import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:al_mahhaba_school/features/profile/data/models/notification_preferences_model.dart';
import 'package:al_mahhaba_school/features/profile/data/models/profile_model.dart';
import 'package:al_mahhaba_school/features/profile/data/models/update_language_request_model.dart';
import 'package:al_mahhaba_school/features/profile/data/models/update_notification_preferences_request_model.dart';

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(@Named(ApiNames.school) this._api);

  final ApiService _api;

  @override
  Future<ProfileModel> getProfile() async {
    // { "status": "success", "data": { "name": "…", "phone": "…",
    //   "language": "en", "children": […], "school_contact": {…} } }
    final json = await _api.get(ApiEndpoints.profile) as Map<String, dynamic>;
    return ProfileModel.fromJson(json[ApiKeys.data] as Map<String, dynamic>);
  }

  @override
  Future<void> updateLanguage(UpdateLanguageRequestModel request) =>
      _api.put(ApiEndpoints.profileLanguage, data: request.toJson());

  @override
  Future<void> deleteAccount() => _api.delete(ApiEndpoints.account);

  @override
  Future<NotificationPreferencesModel> getNotificationPreferences() async {
    // { "status": "success", "data": { "push_enabled": true,
    //   "preferences": { "attendance": true, …, "fees": false } } }
    final json =
        await _api.get(ApiEndpoints.notificationPreferences)
            as Map<String, dynamic>;
    return NotificationPreferencesModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }

  @override
  Future<NotificationPreferencesModel> updateNotificationPreferences(
    UpdateNotificationPreferencesRequestModel request,
  ) async {
    // The same as the GET, with the change.
    final json =
        await _api.put(
              ApiEndpoints.notificationPreferences,
              data: request.toJson(),
            )
            as Map<String, dynamic>;
    return NotificationPreferencesModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }
}
