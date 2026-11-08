import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/network/api_keys.dart';

/// Encrypted storage for sensitive data such as auth tokens.
///
/// The access token is read once and kept in memory: every request sends
/// it, and each read from the phone's keystore is slow.
@lazySingleton
class SecureStorage {
  SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  /// The access token as read (or saved), once it was.
  Future<String?>? _accessToken;

  Future<String?> get accessToken async {
    final read = _accessToken ??= _storage.read(key: ApiKeys.accessToken);
    try {
      return await read;
    } catch (_) {
      // Unreadable now: read again next time.
      if (identical(_accessToken, read)) _accessToken = null;
      rethrow;
    }
  }

  Future<String?> get refreshToken => _storage.read(key: ApiKeys.refreshToken);

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: ApiKeys.accessToken, value: accessToken);
    _accessToken = Future.value(accessToken);
    if (refreshToken != null) {
      await _storage.write(key: ApiKeys.refreshToken, value: refreshToken);
    }
  }

  Future<void> clearTokens() async {
    _accessToken = Future.value();
    await _storage.delete(key: ApiKeys.accessToken);
    await _storage.delete(key: ApiKeys.refreshToken);
  }
}
