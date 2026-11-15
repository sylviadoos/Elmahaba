/// The body of `PUT …/notification-preferences`: only what changes.
class UpdateNotificationPreferencesRequestModel {
  const UpdateNotificationPreferencesRequestModel({
    this.pushEnabled,
    this.categories = const {},
  });

  /// The master switch; null leaves it as it is.
  final bool? pushEnabled;

  /// Kind → on.
  final Map<String, bool> categories;

  /// { "push_enabled": false } or { "preferences": { "fees": false } }
  Map<String, dynamic> toJson() => {
    if (pushEnabled != null) 'push_enabled': pushEnabled,
    if (categories.isNotEmpty) 'preferences': categories,
  };
}
