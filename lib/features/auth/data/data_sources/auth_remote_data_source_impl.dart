import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:al_mahhaba_school/features/auth/data/models/auth_session_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/change_password_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/complete_register_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/login_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/register_eligibility_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/register_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/reset_password_request_model.dart';

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(@Named(ApiNames.school) this._api);

  final ApiService _api;

  @override
  Future<RegisterEligibilityModel> checkPhone(
    RegisterRequestModel request,
  ) async {
    // { "status": "success", "code": "registration_eligible",
    //   "data": { "phone_masked": "0120****154", "eligible": true,
    //             "already_registered": false } }
    final json =
        await _api.post(ApiEndpoints.registerCheckPhone, data: request.toJson())
            as Map<String, dynamic>;
    return RegisterEligibilityModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }

  @override
  Future<AuthSessionModel> completeRegistration(
    CompleteRegisterRequestModel request,
  ) async {
    // { "status": "success", "code": "registered",
    //   "data": { "access_token": "<jwt>", "token_type": "bearer",
    //             "parent": {...}, "children": [...], "next_screen": "home" } }
    final json =
        await _api.post(ApiEndpoints.registerComplete, data: request.toJson())
            as Map<String, dynamic>;
    return AuthSessionModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }

  @override
  Future<AuthSessionModel> login(LoginRequestModel request) async {
    // { "status": "success",
    //   "data": { "access_token": "<jwt>", "token_type": "bearer",
    //             "parent": {...}, "children": [...], "next_screen": "home" } }
    final json =
        await _api.post(ApiEndpoints.login, data: request.toJson())
            as Map<String, dynamic>;
    return AuthSessionModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> checkSession() async {
    // Only whether it succeeds matters for now; the body isn't read.
    await _api.get(ApiEndpoints.session);
  }

  @override
  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    // { "status": "success", "code": "password_reset", "data": null,
    //   "message": "Your new password has been set. Please log in." }
    await _api.post(ApiEndpoints.forgotPassword, data: request.toJson());
  }

  @override
  Future<void> changePassword(ChangePasswordRequestModel request) async {
    // { "status": "success", "code": "password_changed",
    //   "data": { "other_sessions_ended": 1 },
    //   "message": "Your password has been changed." }
    await _api.post(ApiEndpoints.changePassword, data: request.toJson());
  }
}
