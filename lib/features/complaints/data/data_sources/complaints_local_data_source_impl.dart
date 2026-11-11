import 'dart:convert';

import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/storage/shared_pref_helper.dart';
import 'package:al_mahhaba_school/features/complaints/data/data_sources/complaints_local_data_source.dart';

/// Plain preferences: dates only, nothing of the complaints themselves.
@LazySingleton(as: ComplaintsLocalDataSource)
class ComplaintsLocalDataSourceImpl implements ComplaintsLocalDataSource {
  ComplaintsLocalDataSourceImpl(this._preferences);

  final SharedPrefHelper _preferences;

  static const _seenUpdateKey = 'complaints_seen_update';

  /// `{ "12": "2026-11-11T08:15:00.000Z" }`: complaint id → when the parent
  /// changed it.
  static const _ownUpdatesKey = 'complaints_own_updates';

  @override
  DateTime? getSeenUpdate() {
    final saved = _preferences.getString(_seenUpdateKey);
    if (saved == null) return null;
    return DateTime.tryParse(saved)?.toLocal();
  }

  @override
  Future<void> saveSeenUpdate(DateTime updatedAt) => _preferences.saveString(
    key: _seenUpdateKey,
    // UTC: the phone's time zone may change between runs.
    value: updatedAt.toUtc().toIso8601String(),
  );

  @override
  Map<int, DateTime> getOwnUpdates() {
    final saved = _preferences.getString(_ownUpdatesKey);
    if (saved == null) return {};
    try {
      final json = jsonDecode(saved) as Map<String, dynamic>;
      return {
        for (final MapEntry(:key, :value) in json.entries)
          if (int.tryParse(key) case final id?)
            if (DateTime.tryParse('$value') case final updatedAt?)
              id: updatedAt.toLocal(),
      };
    } on FormatException {
      return {};
    } on TypeError {
      return {};
    }
  }

  @override
  Future<void> saveOwnUpdates(Map<int, DateTime> updates) {
    if (updates.isEmpty) return _preferences.removeData(_ownUpdatesKey);
    return _preferences.saveString(
      key: _ownUpdatesKey,
      value: jsonEncode({
        for (final MapEntry(:key, :value) in updates.entries)
          '$key': value.toUtc().toIso8601String(),
      }),
    );
  }

  @override
  Future<void> clearSeenUpdate() async {
    await _preferences.removeData(_seenUpdateKey);
    await _preferences.removeData(_ownUpdatesKey);
  }
}
