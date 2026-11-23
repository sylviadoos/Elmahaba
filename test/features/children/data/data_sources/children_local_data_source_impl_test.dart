import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/children/data/data_sources/children_local_data_source_impl.dart';

import '../../children_fixtures.dart';

/// The phone's encrypted storage, in memory.
class _Storage implements FlutterSecureStorage {
  final Map<String, String> values = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => value == null ? values.remove(key) : values[key] = value;

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values.remove(key);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  late _Storage storage;
  late ChildrenLocalDataSourceImpl dataSource;

  setUp(() {
    storage = _Storage();
    dataSource = ChildrenLocalDataSourceImpl(storage);
  });

  test('none picked yet: none', () async {
    expect(await dataSource.getSelectedChildId(), isNull);
  });

  test('the one picked comes back, as the next launch reads it', () async {
    await dataSource.saveSelectedChildId(1202);

    expect(
      await ChildrenLocalDataSourceImpl(storage).getSelectedChildId(),
      1202,
    );
  });

  test('logged out: the children and the one picked are forgotten, '
      'so the next parent opens on their own first child', () async {
    await dataSource.saveChildren([ereny]);
    await dataSource.saveSelectedChildId(1202);

    await dataSource.clearChildren();

    expect(await dataSource.getSavedChildren(), isEmpty);
    expect(await dataSource.getSelectedChildId(), isNull);
  });

  test('unreadable: none, and the first child shows', () async {
    storage.values['selected_child'] = 'not a number';

    expect(await dataSource.getSelectedChildId(), isNull);
  });
}
