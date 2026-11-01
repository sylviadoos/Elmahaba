import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/network/api_keys.dart';

/// Encrypted storage for sensitive data such as auth tokens.
@lazySingleton
class SecureStorage {
  SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<String?> get accessToken => _storage.read(key: ApiKeys.accessToken);

  Future<String?> get refreshToken => _storage.read(key: ApiKeys.refreshToken);

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: ApiKeys.accessToken, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: ApiKeys.refreshToken, value: refreshToken);
    }
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: ApiKeys.accessToken);
    await _storage.delete(key: ApiKeys.refreshToken);
  }
}
