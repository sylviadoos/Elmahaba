sealed class ProfileEvent {
  const ProfileEvent();
}

/// Loads the parent's account, unless it's loading.
final class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

/// Saves the account's language; the page then switches the app to it.
final class ChangeLanguageEvent extends ProfileEvent {
  const ChangeLanguageEvent(this.language);

  /// "en" or "ar".
  final String language;
}

/// Deletes the parent's account (after they confirmed it).
final class DeleteAccountEvent extends ProfileEvent {
  const DeleteAccountEvent();
}

/// Loads which notifications ring the phone, unless it's loading. Also
/// "Try again".
final class LoadNotificationsEvent extends ProfileEvent {
  const LoadNotificationsEvent();
}

/// Turns notifications on or off (the master switch). Back on, each kind
/// is as it was.
final class SetNotificationsEvent extends ProfileEvent {
  const SetNotificationsEvent({required this.on});

  final bool on;
}

/// Turns one kind of notification on or off, e.g. "fees".
final class SetNotificationCategoryEvent extends ProfileEvent {
  const SetNotificationCategoryEvent(this.category, {required this.on});

  final String category;
  final bool on;
}
