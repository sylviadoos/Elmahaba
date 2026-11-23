import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/features/app_version/data/data_sources/app_version_remote_data_source_impl.dart';

import '../../app_version_fixtures.dart';
import '../../app_version_mocks.mocks.dart';

void main() {
  late MockApiService api;
  late AppVersionRemoteDataSourceImpl dataSource;

  setUp(() {
    api = MockApiService();
    dataSource = AppVersionRemoteDataSourceImpl(api);
  });

  test('asks for this platform and version, and reads the answer', () async {
    when(
      api.get(
        ApiEndpoints.appVersion,
        queryParameters: {'platform': 'android', 'current_version': '2.0.0'},
      ),
    ).thenAnswer((_) async => {'status': 'success', 'data': optional.toJson()});

    expect(
      await dataSource.check(platform: 'android', currentVersion: '2.0.0'),
      optional,
    );
  });

  test('fails: the error goes on', () async {
    when(
      api.get(any, queryParameters: anyNamed('queryParameters')),
    ).thenThrow(const NetworkException());

    expect(
      dataSource.check(platform: 'ios', currentVersion: '1.0.0'),
      throwsA(isA<NetworkException>()),
    );
  });
}
