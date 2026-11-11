import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/app_status/data/data_sources/app_status_remote_data_source.dart';
import 'package:al_mahhaba_school/features/app_status/data/models/app_status_model.dart';
import 'package:al_mahhaba_school/features/app_status/data/repos/app_status_repo_impl.dart';

import '../../../../helpers/result_matchers.dart';
import 'app_status_repo_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AppStatusRemoteDataSource>()])
void main() {
  late MockAppStatusRemoteDataSource remoteDataSource;
  late AppStatusRepoImpl repo;

  setUp(() {
    remoteDataSource = MockAppStatusRemoteDataSource();
    repo = AppStatusRepoImpl(remoteDataSource);
  });

  test('what the school says', () async {
    const status = AppStatusModel(enabled: true);
    when(remoteDataSource.getAppStatus()).thenAnswer((_) async => status);

    expect(await repo.getAppStatus(), isSuccess(status));
  });

  test('can\'t reach it: fails with the error', () async {
    when(remoteDataSource.getAppStatus()).thenThrow(const NetworkException());

    expect(await repo.getAppStatus(), isFailure<NetworkException>());
  });
}
