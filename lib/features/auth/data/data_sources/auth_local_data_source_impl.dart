import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/constants/app_constants.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';
import 'package:al_mahhaba_school/core/storage/secure_storage.dart';
import 'package:al_mahhaba_school/core/storage/shared_pref_helper.dart';
import 'package:al_mahhaba_school/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:al_mahhaba_school/features/auth/data/models/client_info_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/parent_model.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/parent_entity.dart';

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(
    this._secureStorage,
    this._storage,
    this._prefs,
    this._deviceInfo,
    this._notifications,
  );

  final SecureStorage _secureStorage;

  /// Encrypted, like the token: the parent's name and phone.
  final FlutterSecureStorage _storage;
  final SharedPrefHelper _prefs;
  final DeviceInfoPlugin _deviceInfo;
  final NotificationService _notifications;

  static const _parentKey = 'parent';

  /// How long signing in waits for the push token, e.g. on a weak network.
  static const _pushTokenTimeout = Duration(seconds: 5);

  @override
  Future<void> saveToken(String accessToken) =>
      _secureStorage.saveTokens(accessToken: accessToken);

  @override
  Future<bool> hasToken() async {
    try {
      final token = await _secureStorage.accessToken;
      return token != null && token.isNotEmpty;
    } catch (_) {
      // Unreadable storage (e.g. restored from a backup): not signed in.
      return false;
    }
  }

  @override
  Future<void> clearToken() => _secureStorage.clearTokens();

  @override
  Future<void> saveParent(ParentEntity parent) => _storage.write(
    key: _parentKey,
    value: jsonEncode(ParentModel.fromEntity(parent).toJson()),
  );

  @override
  Future<ParentModel?> getSavedParent() async {
    try {
      final saved = await _storage.read(key: _parentKey);
      if (saved == null) return null;
      return ParentModel.fromJson(jsonDecode(saved) as Map<String, dynamic>);
    } catch (_) {
      // Unreadable (old format, restored backup…): the next log in saves it.
      return null;
    }
  }

  @override
  Future<void> clearParent() => _storage.delete(key: _parentKey);

  @override
  Future<ClientInfoModel> clientInfo() async {
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    return ClientInfoModel(
      language:
          _prefs.getString(AppConstants.languageCode) ?? AppConstants.enKey,
      deviceName: await _deviceName(isIos: isIos),
      platform: isIos ? 'ios' : 'android',
      pushToken: await _pushToken(),
    );
  }

  /// Null without one (refused, no Google Play…), or when it's slow: never
  /// blocks signing in.
  Future<String?> _pushToken() => _notifications
      .getToken()
      // A Future<String?> for sure, so the timeout can answer null.
      .then<String?>((token) => token)
      .timeout(_pushTokenTimeout, onTimeout: () => null);

  Future<String> _deviceName({required bool isIos}) async {
    try {
      if (isIos) return (await _deviceInfo.iosInfo).modelName;
      final android = await _deviceInfo.androidInfo;
      return '${android.manufacturer} ${android.model}';
    } catch (_) {
      // Only informative for the school — never block signing in.
      return 'Unknown device';
    }
  }
}
