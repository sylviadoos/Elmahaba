import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/auth/data/data_sources/auth_remote_data_source_impl.dart';
import 'package:al_mahhaba_school/features/auth/data/models/change_password_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/complete_register_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/login_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/register_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/reset_password_request_model.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/complete_register_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_proof_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/reset_password_request_entity.dart';

import '../../auth_fixtures.dart';
import 'auth_remote_data_source_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ApiService>()])
void main() {
  late MockApiService api;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    api = MockApiService();
    dataSource = AuthRemoteDataSourceImpl(api);
  });

  /// The app and device details sent with log in and sign-up.
  final clientJson = {
    'language': 'en',
    'device_name': 'samsung SM-A515F',
    'platform': 'android',
    'push_token': null,
  };

  group('checkPhone', () {
    final request = RegisterRequestModel.fromEntity(registerRequest);

    test('posts the mobile and passwords, reads the eligibility', () async {
      when(
        api.post(ApiEndpoints.registerCheckPhone, data: anyNamed('data')),
      ).thenAnswer(
        (_) async => {
          'status': 'success',
          'code': 'registration_eligible',
          'data': {
            'phone_masked': '0101****678',
            'eligible': true,
            'already_registered': false,
          },
        },
      );

      expect(await dataSource.checkPhone(request), eligibility);
      verify(
        api.post(
          ApiEndpoints.registerCheckPhone,
          data: {
            'phone_number': phone,
            'password': password,
            'password_confirmation': password,
          },
        ),
      ).called(1);
    });

    test('not in the school records: throws the ServerException', () async {
      when(
        api.post(ApiEndpoints.registerCheckPhone, data: anyNamed('data')),
      ).thenThrow(const ServerException(code: 'registration_not_eligible'));

      await expectLater(
        dataSource.checkPhone(request),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('login', () {
    final request = LoginRequestModel.fromEntity(loginRequest, client: client);

    test('posts the mobile, password and device, reads the session', () async {
      when(
        api.post(ApiEndpoints.login, data: anyNamed('data')),
      ).thenAnswer((_) async => {'status': 'success', 'data': sessionJson});

      final result = await dataSource.login(request);

      expect(result, session);
      expect(result.accessToken, 'jwt-token');
      expect(result.parent, parent);
      expect(result.children.single.studentId, 9);
      verify(
        api.post(
          ApiEndpoints.login,
          data: {'phone_number': phone, 'password': password, ...clientJson},
        ),
      ).called(1);
    });

    test('wrong password: throws the ServerException', () async {
      when(api.post(ApiEndpoints.login, data: anyNamed('data'))).thenThrow(
        const ServerException(statusCode: 401, code: 'invalid_credentials'),
      );

      await expectLater(
        dataSource.login(request),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('completeRegistration', () {
    test('posts the number, password, proof and device', () async {
      when(
        api.post(ApiEndpoints.registerComplete, data: anyNamed('data')),
      ).thenAnswer((_) async => {'status': 'success', 'data': sessionJson});

      final result = await dataSource.completeRegistration(
        CompleteRegisterRequestModel.fromEntity(
          const CompleteRegisterRequestEntity(
            phone: phone,
            password: password,
            proof: FirebaseProof(firebaseIdToken),
          ),
          client: client,
        ),
      );

      expect(result, session);
      verify(
        api.post(
          ApiEndpoints.registerComplete,
          data: {
            'phone_number': phone,
            'password': password,
            'firebase_id_token': firebaseIdToken,
            ...clientJson,
          },
        ),
      ).called(1);
    });
  });

  group('checkSession', () {
    test('asks the session endpoint', () async {
      when(
        api.get(ApiEndpoints.session),
      ).thenAnswer((_) async => {'status': 'success'});

      await dataSource.checkSession();

      verify(api.get(ApiEndpoints.session)).called(1);
    });

    test('an ended session: throws the UnauthorizedException', () async {
      when(
        api.get(ApiEndpoints.session),
      ).thenThrow(const UnauthorizedException());

      await expectLater(
        dataSource.checkSession(),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });

  group('resetPassword', () {
    test('posts the number, its proof and the new password', () async {
      when(
        api.post(ApiEndpoints.forgotPassword, data: anyNamed('data')),
      ).thenAnswer((_) async => {'status': 'success', 'data': null});

      await dataSource.resetPassword(
        ResetPasswordRequestModel.fromEntity(resetRequest),
      );

      verify(
        api.post(
          ApiEndpoints.forgotPassword,
          data: {
            'phone_number': phone,
            'firebase_id_token': firebaseIdToken,
            'password': password,
            'password_confirmation': password,
          },
        ),
      ).called(1);
    });
  });

  test("resetPassword with the school's code: posts it as otp", () async {
    when(
      api.post(ApiEndpoints.forgotPassword, data: anyNamed('data')),
    ).thenAnswer((_) async => {'status': 'success', 'data': null});

    await dataSource.resetPassword(
      ResetPasswordRequestModel.fromEntity(
        const ResetPasswordRequestEntity(
          phone: phone,
          proof: SchoolCodeProof('123456'),
          password: password,
          passwordConfirmation: password,
        ),
      ),
    );

    verify(
      api.post(
        ApiEndpoints.forgotPassword,
        data: {
          'phone_number': phone,
          'otp': '123456',
          'password': password,
          'password_confirmation': password,
        },
      ),
    ).called(1);
  });

  group('changePassword', () {
    final request = ChangePasswordRequestModel.fromEntity(changeRequest);

    test('posts the current and new passwords', () async {
      when(
        api.post(ApiEndpoints.changePassword, data: anyNamed('data')),
      ).thenAnswer((_) async => {'status': 'success'});

      await dataSource.changePassword(request);

      verify(
        api.post(
          ApiEndpoints.changePassword,
          data: {
            'current_password': 'old-pass1',
            'password': password,
            'password_confirmation': password,
          },
        ),
      ).called(1);
    });

    test('wrong current password: throws the ServerException', () async {
      when(
        api.post(ApiEndpoints.changePassword, data: anyNamed('data')),
      ).thenThrow(const ServerException(code: 'current_password_incorrect'));

      await expectLater(
        dataSource.changePassword(request),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
