import 'dart:async';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';

/// Firebase isn't set up in tests: pushes arrive when [arrive] is called.
/// Only [onReceived] works; the rest throws.
class FakePushes implements NotificationService {
  final _received = StreamController<Map<String, dynamic>>.broadcast();

  /// A push comes while the app is open, e.g. `{'type': 'result'}`.
  void arrive([Map<String, dynamic> data = const {'type': 'message'}]) =>
      _received.add(data);

  Future<void> close() => _received.close();

  @override
  Stream<Map<String, dynamic>> get onReceived => _received.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

/// A [FakePushes] in getIt for the pages that listen to pushes
/// (`PageRefresher`, `BadgeRefresher`); closed when the test ends. Call in
/// `setUp`, after any `getIt.reset` of the one before.
FakePushes useFakePushes() {
  final pushes = FakePushes();
  getIt.registerSingleton<NotificationService>(pushes);
  return pushes;
}
