import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/notifications/app_icon_badge.dart';

@LazySingleton(as: AppIconBadge)
class AppIconBadgeImpl implements AppIconBadge {
  /// Asked once: whether the launcher can show a number at all.
  Future<bool>? _supported;

  /// The phones only: the web and desktop have no icon to put it on.
  static bool get _isPhone =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<void> show(int count) async {
    if (!_isPhone) return;
    try {
      if (!await (_supported ??= AppBadgePlus.isSupported())) return;
      await AppBadgePlus.updateBadge(count < 0 ? 0 : count);
    } on Exception catch (e) {
      // Only a number on the icon: the app goes on without it.
      debugPrint('AppIconBadge: $e');
    }
  }
}
