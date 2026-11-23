import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:al_mahhaba_school/features/app_version/data/data_sources/app_version_local_data_source.dart';
import 'package:al_mahhaba_school/features/app_version/data/models/app_version_model.dart';

@LazySingleton(as: AppVersionLocalDataSource)
class AppVersionLocalDataSourceImpl implements AppVersionLocalDataSource {
  AppVersionLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  /// { "for_version": "1.0.0", "update": { …as the API sends it… } }
  static const String _key = 'forced_update';

  @override
  AppVersionModel? forcedUpdate(String installedVersion) {
    final saved = _prefs.getString(_key);
    if (saved == null) return null;
    try {
      final json = jsonDecode(saved) as Map<String, dynamic>;
      if (json['for_version'] != installedVersion) return null;
      final update = AppVersionModel.fromJson(
        json['update'] as Map<String, dynamic>,
      );
      return update.forceUpdate ? update : null;
    } on Object catch (e) {
      // Kept by a build that wrote it otherwise: not a reason to hold back.
      debugPrint('Forced update kept: $e');
      return null;
    }
  }

  @override
  Future<void> saveForcedUpdate(
    String installedVersion,
    AppVersionModel update,
  ) => _prefs.setString(
    _key,
    jsonEncode({'for_version': installedVersion, 'update': update.toJson()}),
  );

  @override
  Future<void> clearForcedUpdate() => _prefs.remove(_key);
}
