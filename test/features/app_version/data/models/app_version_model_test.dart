import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/app_version/data/models/app_version_model.dart';

import '../../app_version_fixtures.dart';

void main() {
  test("the API's example: an optional update", () {
    final model = AppVersionModel.fromJson({
      'update_available': true,
      'force_update': false,
      'latest_version': '2.1.0',
      'minimum_supported_version': '2.0.0',
      'message': 'يتوفر إصدار جديد من التطبيق...',
      'store_url':
          'https://play.google.com/store/apps/details?id=com.almahabbahschools.parents',
    });

    expect(model, optional);
  });

  test('forced: an update, whatever update_available says', () {
    final model = AppVersionModel.fromJson({
      'update_available': false,
      'force_update': true,
    });

    expect(model.forceUpdate, isTrue);
    expect(model.updateAvailable, isTrue);
  });

  test('flags as the database sends them (1 / 0)', () {
    final model = AppVersionModel.fromJson({
      'update_available': 1,
      'force_update': 0,
    });

    expect(model.updateAvailable, isTrue);
    expect(model.forceUpdate, isFalse);
  });

  test('nothing said: up to date', () {
    expect(AppVersionModel.fromJson({}), upToDate);
  });

  test('kept on the phone and read back the same', () {
    expect(AppVersionModel.fromJson(forced.toJson()), forced);
  });
}
