import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:al_mahhaba_school/features/profile/data/models/update_language_request_model.dart';
import 'package:al_mahhaba_school/features/profile/data/models/update_notification_preferences_request_model.dart';
import 'package:al_mahhaba_school/features/profile/domain/entities/notification_preferences_entity.dart';
import 'package:al_mahhaba_school/features/profile/domain/entities/profile_entity.dart';
import 'package:al_mahhaba_school/features/profile/domain/repos/profile_repo.dart';

@LazySingleton(as: ProfileRepo)
class ProfileRepoImpl implements ProfileRepo {
  ProfileRepoImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Result<ProfileEntity>> getProfile() =>
      Result.guard(_remoteDataSource.getProfile);

  @override
  Future<Result<void>> updateLanguage(String language) => Result.guard(
    () => _remoteDataSource.updateLanguage(
      UpdateLanguageRequestModel(language: language),
    ),
  );

  @override
  Future<Result<void>> deleteAccount() =>
      Result.guard(_remoteDataSource.deleteAccount);

  @override
  Future<Result<NotificationPreferencesEntity>> getNotificationPreferences() =>
      Result.guard(_remoteDataSource.getNotificationPreferences);

  @override
  Future<Result<NotificationPreferencesEntity>> updateNotificationPreferences({
    bool? pushEnabled,
    Map<String, bool> categories = const {},
  }) => Result.guard(
    () => _remoteDataSource.updateNotificationPreferences(
      UpdateNotificationPreferencesRequestModel(
        pushEnabled: pushEnabled,
        categories: categories,
      ),
    ),
  );
}
