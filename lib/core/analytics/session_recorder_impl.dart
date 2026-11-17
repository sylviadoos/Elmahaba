import 'package:al_mahhaba_school/core/analytics/clarity.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/core/analytics/session_recorder.dart';

@LazySingleton(as: SessionRecorder)
class SessionRecorderImpl implements SessionRecorder {
  /// The screen last reported, so the same one isn't sent again.
  String? _screen;

  @override
  bool get isEnabled => AppConfig.clarityEnabled;

  @override
  void identify(int parentId) {
    if (!isEnabled) return;
    Clarity.setCustomUserId('$parentId');
  }

  @override
  void forget() {
    if (!isEnabled) return;
    Clarity.startNewSession((_) {});
  }

  @override
  void showScreen(String name) {
    if (!isEnabled || name == _screen) return;
    _screen = name;
    Clarity.setCurrentScreenName(name);
  }
}
