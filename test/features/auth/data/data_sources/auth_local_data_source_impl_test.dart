import 'dart:async';
import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/constants/app_constants.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';
import 'package:al_mahhaba_school/core/storage/secure_storage.dart';
import 'package:al_mahhaba_school/core/storage/shared_pref_helper.dart';
import 'package:al_mahhaba_school/features/auth/data/data_sources/auth_local_data_source_impl.dart';
import 'package:al_mahhaba_school/features/auth/data/models/client_info_model.dart';

import '../../auth_fixtures.dart';
import 'auth_local_data_source_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SecureStorage>(),
  MockSpec<FlutterSecureStorage>(),
  MockSpec<SharedPrefHelper>(),
  MockSpec<DeviceInfoPlugin>(),
  MockSpec<AndroidDeviceInfo>(),
  MockSpec<IosDeviceInfo>(),
  MockSpec<NotificationService>(),
])
void main() {
  late MockSecureStorage secureStorage;
  late MockFlutterSecureStorage storage;
  late MockSharedPrefHelper prefs;
  late MockDeviceInfoPlugin deviceInfo;
  late MockNotificationService notifications;
  late AuthLocalDataSourceImpl dataSource;

  setUp(() {
    secureStorage = MockSecureStorage();
    storage = MockFlutterSecureStorage();
    prefs = MockSharedPrefHelper();
    deviceInfo = MockDeviceInfoPlugin();
    notifications = MockNotificationService();
    dataSource = AuthLocalDataSourceImpl(
      secureStorage,
      storage,
      prefs,
      deviceInfo,
      notifications,
    );
  });

  group('token', () {
    test('saveToken keeps it', () async {
      await dataSource.saveToken('jwt-token');

      verify(secureStorage.saveTokens(accessToken: 'jwt-token')).called(1);
    });

    test('clearToken forgets the tokens', () async {
      await dataSource.clearToken();

      verify(secureStorage.clearTokens()).called(1);
    });
  });

  group('hasToken', () {
    test('a token is kept: true', () async {
      when(secureStorage.accessToken).thenAnswer((_) async => 'jwt-token');

      expect(await dataSource.hasToken(), isTrue);
    });

    test('none is kept: false', () async {
      when(secureStorage.accessToken).thenAnswer((_) async => null);

      expect(await dataSource.hasToken(), isFalse);
    });

    test('an empty one: false', () async {
      when(secureStorage.accessToken).thenAnswer((_) async => '');

      expect(await dataSource.hasToken(), isFalse);
    });

    test('unreadable storage: false', () async {
      when(
        secureStorage.accessToken,
      ).thenThrow(PlatformException(code: 'read_failed'));

      expect(await dataSource.hasToken(), isFalse);
    });
  });

  group('parent', () {
    test('saveParent keeps it as the API sends it', () async {
      await dataSource.saveParent(parent);

      verify(
        storage.write(key: 'parent', value: jsonEncode(parentJson)),
      ).called(1);
    });

    test('getSavedParent reads it back', () async {
      when(
        storage.read(key: 'parent'),
      ).thenAnswer((_) async => jsonEncode(parentJson));

      expect(await dataSource.getSavedParent(), parent);
    });

    test('none saved: null', () async {
      when(storage.read(key: 'parent')).thenAnswer((_) async => null);

      expect(await dataSource.getSavedParent(), isNull);
    });

    test('unreadable (old format…): null', () async {
      when(storage.read(key: 'parent')).thenAnswer((_) async => '{"id": "7"}');

      expect(await dataSource.getSavedParent(), isNull);
    });

    test('clearParent forgets it', () async {
      await dataSource.clearParent();

      verify(storage.delete(key: 'parent')).called(1);
    });
  });

  group('clientInfo', () {
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test(
      'Android: the app language, the phone model and its push token',
      () async {
        final android = MockAndroidDeviceInfo();
        when(android.manufacturer).thenReturn('samsung');
        when(android.model).thenReturn('SM-A515F');
        when(deviceInfo.androidInfo).thenAnswer((_) async => android);
        when(prefs.getString(AppConstants.languageCode)).thenReturn('ar');
        when(notifications.getToken()).thenAnswer((_) async => 'fcm-token');

        final info = await dataSource.clientInfo();

        expect(info.toJson(), {
          'language': 'ar',
          'device_name': 'samsung SM-A515F',
          'platform': 'android',
          'push_token': 'fcm-token',
        });
      },
    );

    test('no push token: signs in without one', () async {
      when(notifications.getToken()).thenAnswer((_) async => null);

      expect((await dataSource.clientInfo()).pushToken, isNull);
    });

    test('the push token is slow: signs in without it', () {
      fakeAsync((async) {
        when(
          notifications.getToken(),
        ).thenAnswer((_) => Completer<String?>().future);

        ClientInfoModel? info;
        dataSource.clientInfo().then((value) => info = value);
        async.elapse(const Duration(seconds: 5));

        expect(info, isNotNull);
        expect(info!.pushToken, isNull);
      });
    });

    test('iPhone: its model name', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final ios = MockIosDeviceInfo();
      when(ios.modelName).thenReturn('iPhone 15 Pro');
      when(deviceInfo.iosInfo).thenAnswer((_) async => ios);

      final info = await dataSource.clientInfo();

      expect(info.deviceName, 'iPhone 15 Pro');
      expect(info.platform, 'ios');
    });

    test('no language chosen yet: English', () async {
      when(prefs.getString(AppConstants.languageCode)).thenReturn(null);

      expect((await dataSource.clientInfo()).language, AppConstants.enKey);
    });

    test("the device can't be read: still signs in", () async {
      when(
        deviceInfo.androidInfo,
      ).thenThrow(PlatformException(code: 'unavailable'));

      expect((await dataSource.clientInfo()).deviceName, 'Unknown device');
    });
  });
}
