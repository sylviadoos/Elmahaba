import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:al_mahhaba_school/features/home/data/models/child_dashboard_model.dart';
import 'package:al_mahhaba_school/features/home/data/repos/home_repo_impl.dart';

import '../../../../helpers/result_matchers.dart';
import '../../home_fixtures.dart';
import 'home_repo_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<HomeRemoteDataSource>()])
void main() {
  const childId = 9;
  late MockHomeRemoteDataSource remoteDataSource;
  late HomeRepoImpl repo;

  final dashboard = ChildDashboardModel.fromJson(dashboardJson);

  setUp(() {
    remoteDataSource = MockHomeRemoteDataSource();
    repo = HomeRepoImpl(remoteDataSource);
  });

  test('getChildDashboard: what the school sent, for that child', () async {
    when(
      remoteDataSource.getChildDashboard(childId),
    ).thenAnswer((_) async => dashboard);

    expect(
      await repo.getChildDashboard(childId),
      isSuccess<Object?>(dashboard),
    );
    verify(remoteDataSource.getChildDashboard(childId)).called(1);
  });

  test('no connection: a failure, not a throw', () async {
    when(
      remoteDataSource.getChildDashboard(any),
    ).thenThrow(const NetworkException());

    expect(
      await repo.getChildDashboard(childId),
      isFailure<NetworkException>(),
    );
  });

  test('the session ended: a failure the UI can tell apart', () async {
    when(
      remoteDataSource.getChildDashboard(any),
    ).thenThrow(const UnauthorizedException());

    expect(
      await repo.getChildDashboard(childId),
      isFailure<UnauthorizedException>(),
    );
  });

  test('an answer it couldn\'t read: an unknown failure, not a crash',
      () async {
    when(
      remoteDataSource.getChildDashboard(any),
    ).thenThrow(TypeError());

    expect(
      await repo.getChildDashboard(childId),
      isFailure<UnknownException>(),
    );
  });
}
