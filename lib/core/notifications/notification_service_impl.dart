import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';

@LazySingleton(as: NotificationService)
class NotificationServiceImpl implements NotificationService {
  NotificationServiceImpl(this._messaging, this._localNotifications);

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  /// Pops up with a sound. The pushes that arrive while the app is closed
  /// use it too (`default_notification_channel_id` in AndroidManifest).
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'school_notifications',
    AppConfig.appName,
    importance: Importance.high,
  );

  /// `res/drawable/ic_notification.xml`: the school's mark.
  static const String _icon = 'ic_notification';

  /// Not broadcast, so the tap that opened the app waits for a listener.
  final StreamController<Map<String, dynamic>> _taps = StreamController();

  /// Firebase is set up for the phones only, not the web or desktop.
  static bool get _isPhone =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<void> init() async {
    if (!_isPhone) return;
    // iOS, and Android 13 and later, ask the parent first.
    await _messaging.requestPermission();
    // iOS shows a push while the app is open itself; Android doesn't, so
    // it gets a local notification instead (_showWhileOpen).
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (_isAndroid) {
      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(_icon),
        ),
        onDidReceiveNotificationResponse: (response) =>
            _tapped(response.payload),
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
    }

    FirebaseMessaging.onMessage.listen(_showWhileOpen);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _taps.add(message.data),
    );
    // The app was closed, and a push opened it.
    final opening = await _messaging.getInitialMessage();
    if (opening != null) _taps.add(opening.data);

    // For sending a test push from the Firebase console.
    if (AppConfig.enableLogging) debugPrint('FCM token: ${await getToken()}');
  }

  // The registration token every server library sends to. FCM 17 deprecates
  // it for an installation ID (register / onRegistered), which the backend
  // would need FCM's new direct-send for.
  @override
  Future<String?> getToken() async {
    if (!_isPhone) return null;
    try {
      // ignore: deprecated_member_use
      return await _messaging.getToken();
    } on Exception catch (e) {
      // e.g. iOS before Apple handed out its own token.
      debugPrint('NotificationService.getToken: $e');
      return null;
    }
  }

  @override
  Stream<String> get onTokenRefresh =>
      // ignore: deprecated_member_use
      _isPhone ? _messaging.onTokenRefresh : const Stream.empty();

  @override
  Stream<Map<String, dynamic>> get onTap => _taps.stream;

  @override
  Stream<Map<String, dynamic>> get onReceived => _isPhone
      // Broadcast, so listening here doesn't take it from _showWhileOpen.
      ? FirebaseMessaging.onMessage.map((message) => message.data)
      : const Stream.empty();

  @override
  Future<void> deleteToken() async {
    // ignore: deprecated_member_use
    if (_isPhone) await _messaging.deleteToken();
  }

  /// Shows [message] as Android would with the app closed; its `data` comes
  /// back as the payload when it's tapped.
  Future<void> _showWhileOpen(RemoteMessage message) async {
    final notification = message.notification;
    if (!_isAndroid || notification == null) return;
    await _localNotifications.show(
      id: (message.messageId ?? '${message.sentTime}').hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          importance: Importance.high,
          priority: Priority.high,
          color: AppColors.mahabbahRed,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _tapped(String? payload) {
    if (payload == null) return;
    _taps.add(Map<String, dynamic>.from(jsonDecode(payload) as Map));
  }
}
