import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/profile/domain/entities/notification_preferences_entity.dart';
import 'package:al_mahhaba_school/features/profile/domain/entities/profile_entity.dart';

/// Four things at once, so the profile stays on screen while the language
/// or notifications are saved or the account deleted.
class ProfileState extends Equatable {
  const ProfileState({
    this.profile = const BaseState.initial(),
    this.language = const BaseState.initial(),
    this.deletion = const BaseState.initial(),
    this.notifications = const BaseState.initial(),
  });

  final BaseState<ProfileEntity> profile;

  /// The last language change; on success, the language saved.
  final BaseState<String> language;

  /// Deleting the account; `true` once deleted.
  final BaseState<bool> deletion;

  /// Which notifications ring the phone. While a change is saved it's
  /// `loading` with the change shown; if that fails, `error` with what was
  /// there before.
  final BaseState<NotificationPreferencesEntity> notifications;

  ProfileState copyWith({
    BaseState<ProfileEntity>? profile,
    BaseState<String>? language,
    BaseState<bool>? deletion,
    BaseState<NotificationPreferencesEntity>? notifications,
  }) => ProfileState(
    profile: profile ?? this.profile,
    language: language ?? this.language,
    deletion: deletion ?? this.deletion,
    notifications: notifications ?? this.notifications,
  );

  @override
  List<Object?> get props => [profile, language, deletion, notifications];
}
