import 'dart:ui';

/// Application-wide constants used across the project.
abstract final class AppConstants {
  /// Size of the design frames — ScreenUtil scales `.w` / `.h` / `.sp`
  /// from this.
  static const Size designSize = Size(390, 844);

  // 🔹 Shared Preferences Keys
  static const String isRemember = 'isRemember';
  static const String userRole = 'userRole';
  static const String userName = 'userName';
  static const String userEmail = 'userEmail';
  static const String languageCode = 'languageCode';
  static const String themeMode = 'themeMode';

  // 🔹 Language codes
  static const String arKey = 'ar';
  static const String enKey = 'en';

  // 🔹 General Constants
  static const Duration animationDuration = Duration(milliseconds: 300);
}
