import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/auth/data/data_sources/school_otp_data_source_impl.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';

import '../../auth_fixtures.dart';
import 'school_otp_data_source_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ApiService>()])
void main() {
  late MockApiService api;
  late SchoolOtpDataSourceImpl dataSource;

  setUp(() {
    api = MockApiService();
    dataSource = SchoolOtpDataSourceImpl(api);
  });

  test("posts the number; SchoolCodeSent with the school's wait", () async {
    when(api.post(ApiEndpoints.otpRequest, data: anyNamed('data'))).thenAnswer(
      (_) async => {
        'status': 'success',
        'code': 'otp_sent',
        'data': {
          'expires_in': 300,
          'resend_after': 45,
          'resends_left': 3,
          'phone_masked': '0101****678',
        },
      },
    );

    expect(
      await dataSource.sendCode(phone),
      const SchoolCodeSent(resendAfter: Duration(seconds: 45)),
    );
    verify(api.post(ApiEndpoints.otpRequest, data: {'phone': phone})).called(1);
  });

  test('no wait given: 60 seconds', () async {
    when(
      api.post(ApiEndpoints.otpRequest, data: anyNamed('data')),
    ).thenAnswer((_) async => {'status': 'success', 'data': null});

    expect(
      await dataSource.sendCode(phone),
      const SchoolCodeSent(resendAfter: Duration(seconds: 60)),
    );
  });

  test("the school refuses: throws its error", () async {
    when(
      api.post(ApiEndpoints.otpRequest, data: anyNamed('data')),
    ).thenThrow(const ServerException(code: 'otp_resend_too_soon'));

    await expectLater(
      dataSource.sendCode(phone),
      throwsA(
        isA<ServerException>().having(
          (e) => e.code,
          'code',
          'otp_resend_too_soon',
        ),
      ),
    );
  });
}
