/// The school's push notifications (Firebase Cloud Messaging).
abstract interface class NotificationService {
  /// Call once at start: asks the parent to allow notifications, shows the
  /// ones that arrive while the app is open, and starts reporting taps
  /// ([onTap]). Does nothing off a phone.
  Future<void> init();

  /// This phone's token, for the backend to send pushes to; null when there
  /// isn't one (no Google Play services, no network, an iOS simulator).
  Future<String?> getToken();

  /// A new token that replaces the old one: to send to the backend again.
  Stream<String> get onTokenRefresh;

  /// The `data` of each notification the parent taps, the one that opened
  /// the app included. One listener; taps before it wait for it.
  Stream<Map<String, dynamic>> get onTap;

  /// Stops pushes to this phone, e.g. on log out; [getToken] then makes a
  /// new token.
  Future<void> deleteToken();
}
