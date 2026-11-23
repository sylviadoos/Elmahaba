import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/app_version/data/models/app_version_model.dart';
import 'package:al_mahhaba_school/features/app_version/data/repos/app_version_repo_impl.dart';
import 'package:al_mahhaba_school/features/app_version/domain/entities/app_version_entity.dart';

import '../../app_version_fixtures.dart';
import '../../app_version_mocks.mocks.dart';

void main() {
  late MockAppVersionRemoteDataSource remote;
  late MockAppVersionLocalDataSource local;
  late MockAppInfoDataSource appInfo;
  late AppVersionRepoImpl repo;

  setUpAll(
    () => provideDummy<AppVersionModel>(
      const AppVersionModel(updateAvailable: false, forceUpdate: false),
    ),
  );

  setUp(() {
    remote = MockAppVersionRemoteDataSource();
    local = MockAppVersionLocalDataSource();
    appInfo = MockAppInfoDataSource();
    repo = AppVersionRepoImpl(remote, local, appInfo);
    when(appInfo.platform).thenReturn('android');
    when(appInfo.version()).thenAnswer((_) async => '1.0.0');
  });

  void schoolSays(AppVersionModel update) => when(
    remote.check(
      platform: anyNamed('platform'),
      currentVersion: anyNamed('currentVersion'),
    ),
  ).thenAnswer((_) async => update);

  AppVersionEntity data(Result<AppVersionEntity> result) =>
      (result as Success<AppVersionEntity>).data;

  test('asks with this phone and the installed version', () async {
    schoolSays(optional);

    await repo.check();

    verify(remote.check(platform: 'android', currentVersion: '1.0.0'));
  });

  test('forced: kept on the phone for this version', () async {
    schoolSays(forced);

    expect(data(await repo.check()), forced);
    verify(local.saveForcedUpdate('1.0.0', forced));
  });

  test('not forced (any more): what was kept is forgotten', () async {
    schoolSays(optional);

    await repo.check();

    verify(local.clearForcedUpdate());
    verifyNever(local.saveForcedUpdate(any, any));
  });

  test("no store page from the school: this app's, for this phone", () async {
    when(appInfo.platform).thenReturn('ios');
    schoolSays(const AppVersionModel(updateAvailable: true, forceUpdate: true));

    expect(data(await repo.check()).storeUrl, AppConfig.iosStoreUrl);
  });

  test("the school can't be reached: a failure, nothing forgotten", () async {
    when(
      remote.check(
        platform: anyNamed('platform'),
        currentVersion: anyNamed('currentVersion'),
      ),
    ).thenThrow(const NetworkException());

    expect(await repo.check(), isA<Failure<AppVersionEntity>>());
    verifyNever(local.clearForcedUpdate());
  });

  test(
    'no store to update from (web, desktop): up to date, nothing asked',
    () async {
      when(appInfo.platform).thenReturn(null);

      expect(data(await repo.check()), AppVersionEntity.upToDate);
      verifyZeroInteractions(remote);
    },
  );

  test('saved: the forced update kept for the installed version', () async {
    when(local.forcedUpdate('1.0.0')).thenReturn(forced);

    expect(await repo.savedForcedUpdate(), forced);
  });
}
