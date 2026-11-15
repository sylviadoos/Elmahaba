import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/app_status/data/data_sources/app_status_remote_data_source_impl.dart';
import 'package:al_mahhaba_school/features/app_status/data/models/app_status_model.dart';

import 'app_status_remote_data_source_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ApiService>()])
void main() {
  late MockApiService api;
  late AppStatusRemoteDataSourceImpl dataSource;

  setUp(() {
    api = MockApiService();
    dataSource = AppStatusRemoteDataSourceImpl(api);
  });

  void respond(Map<String, dynamic> data) => when(
    api.get(ApiEndpoints.appStatus),
  ).thenAnswer((_) async => {'status': 'success', 'data': data});

  test('the API\'s example: enabled, no message', () async {
    respond({'enabled': true, 'message': null});

    expect(
      await dataSource.getAppStatus(),
      const AppStatusModel(enabled: true),
    );
  });

  test('off, with what the school says', () async {
    respond({'enabled': false, 'message': 'Coming soon'});

    expect(
      await dataSource.getAppStatus(),
      const AppStatusModel(enabled: false, message: 'Coming soon'),
    );
  });

  test('not saying: not enabled', () async {
    respond({});

    expect(
      await dataSource.getAppStatus(),
      const AppStatusModel(enabled: false),
    );
  });

  test('fails: the error goes on', () async {
    when(api.get(any)).thenThrow(const NetworkException());

    expect(dataSource.getAppStatus(), throwsA(isA<NetworkException>()));
  });
}
