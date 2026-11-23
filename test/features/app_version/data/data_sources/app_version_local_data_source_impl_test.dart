import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:al_mahhaba_school/features/app_version/data/data_sources/app_version_local_data_source_impl.dart';

import '../../app_version_fixtures.dart';

void main() {
  late AppVersionLocalDataSourceImpl local;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    local = AppVersionLocalDataSourceImpl(
      await SharedPreferences.getInstance(),
    );
  });

  test('kept for this version: read back', () async {
    await local.saveForcedUpdate('1.0.0', forced);

    expect(local.forcedUpdate('1.0.0'), forced);
  });

  test('the app was updated since: nothing', () async {
    await local.saveForcedUpdate('1.0.0', forced);

    expect(local.forcedUpdate('2.1.0'), isNull);
  });

  test('cleared: nothing', () async {
    await local.saveForcedUpdate('1.0.0', forced);
    await local.clearForcedUpdate();

    expect(local.forcedUpdate('1.0.0'), isNull);
  });

  test('something unreadable kept: nothing, no error', () async {
    SharedPreferences.setMockInitialValues({'forced_update': 'not json'});
    local = AppVersionLocalDataSourceImpl(
      await SharedPreferences.getInstance(),
    );

    expect(local.forcedUpdate('1.0.0'), isNull);
  });
}
