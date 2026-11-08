/// The app and device details the school API keeps with each sign-in
/// (log in, sign up). Data only — the app never shows them.
class ClientInfoModel {
  const ClientInfoModel({
    required this.language,
    required this.deviceName,
    required this.platform,
    this.pushToken,
  });

  /// The app's language: "en" or "ar".
  final String language;

  /// e.g. "samsung SM-A515F" or "iPhone 15 Pro".
  final String deviceName;

  /// "android" or "ios".
  final String platform;

  /// This phone's FCM token, for the school's notifications; null when
  /// there's none.
  final String? pushToken;

  Map<String, dynamic> toJson() => {
    'language': language,
    'device_name': deviceName,
    'platform': platform,
    'push_token': pushToken,
  };
}
