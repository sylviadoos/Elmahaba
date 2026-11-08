import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/profile/domain/entities/notification_preferences_entity.dart';
import 'package:al_mahhaba_school/features/profile/domain/use_cases/delete_account_use_case.dart';
import 'package:al_mahhaba_school/features/profile/domain/use_cases/get_notification_preferences_use_case.dart';
import 'package:al_mahhaba_school/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:al_mahhaba_school/features/profile/domain/use_cases/update_language_use_case.dart';
import 'package:al_mahhaba_school/features/profile/domain/use_cases/update_notification_preferences_use_case.dart';
import 'package:al_mahhaba_school/features/profile/presentation/view_model/profile_event.dart';
import 'package:al_mahhaba_school/features/profile/presentation/view_model/profile_state.dart';

/// The parent's account on Settings: loading it, its language, its
/// notifications, deleting it. One per Settings page. The page switches the
/// app's language and logs out itself, hence `void`.
@injectable
class ProfileViewModel extends BaseCubit<ProfileState, ProfileEvent, void> {
  ProfileViewModel(
    this._getProfile,
    this._updateLanguage,
    this._deleteAccount,
    this._getNotificationPreferences,
    this._updateNotificationPreferences,
  ) : super(const ProfileState());

  final GetProfileUseCase _getProfile;
  final UpdateLanguageUseCase _updateLanguage;
  final DeleteAccountUseCase _deleteAccount;
  final GetNotificationPreferencesUseCase _getNotificationPreferences;
  final UpdateNotificationPreferencesUseCase _updateNotificationPreferences;

  @override
  Future<void> doAction(ProfileEvent event) async {
    switch (event) {
      case LoadProfileEvent():
        await _load();
      case ChangeLanguageEvent(:final language):
        await _changeLanguage(language);
      case DeleteAccountEvent():
        await _delete();
      case LoadNotificationsEvent():
        await _loadNotifications();
      case SetNotificationsEvent(:final on):
        await _saveNotifications(pushEnabled: on);
      case SetNotificationCategoryEvent(:final category, :final on):
        await _saveNotifications(categories: {category: on});
    }
  }

  Future<void> _load() async {
    if (state.profile.state == StateType.loading) return;
    emit(state.copyWith(profile: const BaseState.loading()));
    final result = await _getProfile();
    if (isClosed) return;
    emit(
      state.copyWith(
        profile: result.when(
          success: BaseState.success,
          failure: BaseState.error,
        ),
      ),
    );
  }

  /// The account first: the app switches once it's saved, so the two
  /// never differ.
  Future<void> _changeLanguage(String language) async {
    if (state.language.state == StateType.loading) return;
    emit(state.copyWith(language: const BaseState.loading()));
    final result = await _updateLanguage(language);
    if (isClosed) return;
    emit(
      state.copyWith(
        language: result.when(
          success: (_) => BaseState.success(language),
          failure: BaseState.error,
        ),
      ),
    );
  }

  Future<void> _delete() async {
    if (state.deletion.state == StateType.loading) return;
    emit(state.copyWith(deletion: const BaseState.loading()));
    final result = await _deleteAccount();
    if (isClosed) return;
    emit(
      state.copyWith(
        deletion: result.when(
          success: (_) => const BaseState.success(true),
          failure: BaseState.error,
        ),
      ),
    );
  }

  Future<void> _loadNotifications() async {
    if (state.notifications.state == StateType.loading) return;
    emit(state.copyWith(notifications: const BaseState.loading()));
    final result = await _getNotificationPreferences();
    if (isClosed) return;
    emit(
      state.copyWith(
        notifications: result.when(
          success: BaseState.success,
          failure: BaseState.error,
        ),
      ),
    );
  }

  /// Saves only what changes; shown at once, back as it was if it can't be
  /// saved.
  Future<void> _saveNotifications({
    bool? pushEnabled,
    Map<String, bool> categories = const {},
  }) async {
    final shown = state.notifications.data;
    if (shown == null || state.notifications.state == StateType.loading) {
      return;
    }
    final changed = NotificationPreferencesEntity(
      pushEnabled: pushEnabled ?? shown.pushEnabled,
      categories: {...shown.categories, ...categories},
    );
    emit(
      state.copyWith(
        notifications: BaseState.all(
          state: StateType.loading,
          data: changed,
          exception: null,
        ),
      ),
    );
    final result = await _updateNotificationPreferences(
      pushEnabled: pushEnabled,
      categories: categories,
    );
    if (isClosed) return;
    emit(
      state.copyWith(
        notifications: result.when(
          success: BaseState.success,
          failure: (exception) => BaseState.all(
            state: StateType.error,
            data: shown,
            exception: exception,
          ),
        ),
      ),
    );
  }
}
