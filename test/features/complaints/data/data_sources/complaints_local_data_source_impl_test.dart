import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:al_mahhaba_school/core/storage/shared_pref_helper.dart';
import 'package:al_mahhaba_school/features/complaints/data/data_sources/complaints_local_data_source_impl.dart';

void main() {
  late ComplaintsLocalDataSourceImpl dataSource;

  Future<void> start([Map<String, Object> saved = const {}]) async {
    SharedPreferences.setMockInitialValues(saved);
    dataSource = ComplaintsLocalDataSourceImpl(
      SharedPrefHelper(await SharedPreferences.getInstance()),
    );
  }

  test('nothing saved yet: the parent has read nothing', () async {
    await start();

    expect(dataSource.getSeenUpdate(), isNull);
  });

  test('what was saved comes back, as local time', () async {
    await start();
    final seen = DateTime(2026, 11, 8, 17, 30);

    await dataSource.saveSeenUpdate(seen);

    expect(dataSource.getSeenUpdate(), seen);
    expect(dataSource.getSeenUpdate()?.isUtc, isFalse);
  });

  test('saved in another time zone: the same moment', () async {
    await start({'complaints_seen_update': '2026-11-08T15:30:00.000Z'});

    expect(
      dataSource.getSeenUpdate(),
      DateTime.utc(2026, 11, 8, 15, 30).toLocal(),
    );
  });

  test('unreadable: as if nothing was read', () async {
    await start({'complaints_seen_update': 'last Tuesday'});

    expect(dataSource.getSeenUpdate(), isNull);
  });

  test('the parent'
      's own changes: none until saved', () async {
    await start();

    expect(dataSource.getOwnUpdates(), isEmpty);
  });

  test('the parent'
      's own changes come back, as local time', () async {
    await start();
    final own = {7: DateTime(2026, 11, 11, 10, 15), 12: DateTime(2026, 11, 3)};

    await dataSource.saveOwnUpdates(own);

    expect(dataSource.getOwnUpdates(), own);
  });

  test('the parent'
      's own changes unreadable: none', () async {
    await start({'complaints_own_updates': '[1, 2]'});

    expect(dataSource.getOwnUpdates(), isEmpty);
  });

  test('cleared on log out, with the parent'
      's own changes', () async {
    await start();
    await dataSource.saveSeenUpdate(DateTime(2026, 11, 8));
    await dataSource.saveOwnUpdates({7: DateTime(2026, 11, 8)});

    await dataSource.clearSeenUpdate();

    expect(dataSource.getSeenUpdate(), isNull);
    expect(dataSource.getOwnUpdates(), isEmpty);
  });
}
