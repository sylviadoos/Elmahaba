import 'package:equatable/equatable.dart';

/// Which notifications ring the phone: all of them ([pushEnabled]), and
/// each kind the school sends. One turned off still shows in the app, it
/// just doesn't ring.
class NotificationPreferencesEntity extends Equatable {
  const NotificationPreferencesEntity({
    required this.pushEnabled,
    required this.categories,
  });

  /// The master switch. Off, the phone never rings; [categories] keep their
  /// choices for when it's back on.
  final bool pushEnabled;

  /// Kind → on, by the school's names for them ("attendance", "results",
  /// "fees", "messages"…), in the school's order.
  final Map<String, bool> categories;

  @override
  List<Object?> get props => [pushEnabled, categories];
}
