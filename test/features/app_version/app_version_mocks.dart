// What the app version feature uses, mocked once for its tests. Regenerate
// with `dart run build_runner build`. (mockito reads the annotation on an
// import, not on `library`.)
@GenerateNiceMocks([
  MockSpec<ApiService>(),
  MockSpec<AppVersionRemoteDataSource>(),
  MockSpec<AppVersionLocalDataSource>(),
  MockSpec<AppInfoDataSource>(),
  MockSpec<CheckAppVersionUseCase>(),
  MockSpec<GetSavedForcedUpdateUseCase>(),
])
import 'package:mockito/annotations.dart';

import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/app_version/data/data_sources/app_info_data_source.dart';
import 'package:al_mahhaba_school/features/app_version/data/data_sources/app_version_local_data_source.dart';
import 'package:al_mahhaba_school/features/app_version/data/data_sources/app_version_remote_data_source.dart';
import 'package:al_mahhaba_school/features/app_version/domain/use_cases/check_app_version_use_case.dart';
import 'package:al_mahhaba_school/features/app_version/domain/use_cases/get_saved_forced_update_use_case.dart';
