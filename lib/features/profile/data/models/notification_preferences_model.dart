import 'package:al_mahhaba_school/features/profile/domain/entities/notification_preferences_entity.dart';

class NotificationPreferencesModel extends NotificationPreferencesEntity {
  const NotificationPreferencesModel({
    required super.pushEnabled,
    required super.categories,
  });

  /// { "push_enabled": true, "preferences": { "attendance": true,
  ///   "announcements": true, "homework": true, "results": true,
  ///   "fees": false, "messages": true } }
  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    final preferences = json['preferences'];
    return NotificationPreferencesModel(
      // All on by default, as the school sets them.
      pushEnabled: json['push_enabled'] as bool? ?? true,
      categories: {
        if (preferences is Map<String, dynamic>)
          for (final MapEntry(:key, :value) in preferences.entries)
            if (value is bool) key: value,
      },
    );
  }
}
