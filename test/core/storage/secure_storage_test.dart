import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/storage/secure_storage.dart';

import 'secure_storage_test.mocks.dart';

@GenerateNiceMocks([MockSpec<FlutterSecureStorage>()])
void main() {
  late MockFlutterSecureStorage storage;
  late SecureStorage secureStorage;

  setUp(() {
    storage = MockFlutterSecureStorage();
    secureStorage = SecureStorage(storage);
  });

  group('accessToken', () {
    test('read from the keystore once, then from memory', () async {
      when(
        storage.read(key: ApiKeys.accessToken),
      ).thenAnswer((_) async => 'token-1');

      expect(await secureStorage.accessToken, 'token-1');
      expect(await secureStorage.accessToken, 'token-1');
      verify(storage.read(key: ApiKeys.accessToken)).called(1);
    });

    test('saved: the new one, without reading it back', () async {
      await secureStorage.saveTokens(accessToken: 'token-2');

      expect(await secureStorage.accessToken, 'token-2');
      verify(
        storage.write(key: ApiKeys.accessToken, value: 'token-2'),
      ).called(1);
      verifyNever(storage.read(key: ApiKeys.accessToken));
    });

    test('cleared: none, without reading', () async {
      await secureStorage.saveTokens(accessToken: 'token-2');
      await secureStorage.clearTokens();

      expect(await secureStorage.accessToken, isNull);
      verifyNever(storage.read(key: ApiKeys.accessToken));
    });

    test('unreadable: fails, and is read again next time', () async {
      when(
        storage.read(key: ApiKeys.accessToken),
      ).thenThrow(PlatformException(code: 'keystore'));
      await expectLater(
        secureStorage.accessToken,
        throwsA(isA<PlatformException>()),
      );

      when(
        storage.read(key: ApiKeys.accessToken),
      ).thenAnswer((_) async => 'token-1');
      expect(await secureStorage.accessToken, 'token-1');
    });
  });
}
