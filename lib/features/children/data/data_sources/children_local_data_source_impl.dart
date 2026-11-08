import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/children/data/data_sources/children_local_data_source.dart';
import 'package:al_mahhaba_school/features/children/data/models/child_model.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';

/// Encrypted, like the token: it's children's names and ID digits.
@LazySingleton(as: ChildrenLocalDataSource)
class ChildrenLocalDataSourceImpl implements ChildrenLocalDataSource {
  ChildrenLocalDataSourceImpl(this._storage);

  final FlutterSecureStorage _storage;

  static const _childrenKey = 'children';

  @override
  Future<List<ChildModel>> getSavedChildren() async {
    try {
      final saved = await _storage.read(key: _childrenKey);
      if (saved == null) return const [];
      return [
        for (final child in jsonDecode(saved) as List<dynamic>)
          ChildModel.fromJson(child as Map<String, dynamic>),
      ];
    } catch (_) {
      // Unreadable (old format, restored backup…): the API refills it.
      return const [];
    }
  }

  @override
  Future<void> saveChildren(List<ChildEntity> children) => _storage.write(
    key: _childrenKey,
    value: jsonEncode([
      for (final child in children) ChildModel.fromEntity(child).toJson(),
    ]),
  );

  @override
  Future<void> clearChildren() => _storage.delete(key: _childrenKey);
}
