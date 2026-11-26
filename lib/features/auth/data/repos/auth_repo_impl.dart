import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:al_mahhaba_school/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:al_mahhaba_school/features/auth/data/data_sources/phone_verification_data_source.dart';
import 'package:al_mahhaba_school/features/auth/data/data_sources/school_otp_data_source.dart';
import 'package:al_mahhaba_school/features/auth/data/models/auth_session_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/change_password_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/complete_register_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/login_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/parent_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/register_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/reset_password_request_model.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/auth_session_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/change_password_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/complete_register_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/login_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/parent_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/register_eligibility_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/register_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/reset_password_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/session_status.dart';
import 'package:al_mahhaba_school/features/auth/domain/repos/auth_repo.dart';
import 'package:al_mahhaba_school/features/auth/domain/school_sms_down.dart';
import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_local_data_source.dart';
import 'package:al_mahhaba_school/features/children/data/data_sources/children_local_data_source.dart';

@LazySingleton(as: AuthRepo)
class AuthRepoImpl implements AuthRepo {
  AuthRepoImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._phoneVerification,
    this._schoolOtp,
    this._childrenLocalDataSource,
    this._chatLocalDataSource,
    @Named(AppConfig.smsMisrFirstName) this._smsMisrFirst,
  );

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final PhoneVerificationDataSource _phoneVerification;

  /// The school's own SMS (SMS Misr): first, or when Firebase can't send.
  final SchoolOtpDataSource _schoolOtp;

  /// Whether the school sends the codes first (`AppConfig.smsMisrFirst`),
  /// Firebase only when it fails; else the other way round.
  final bool _smsMisrFirst;

  /// The session's children are saved and forgotten with it.
  final ChildrenLocalDataSource _childrenLocalDataSource;

  /// The chats kept in memory are forgotten with it.
  final ChatLocalDataSource _chatLocalDataSource;

  @override
  Future<Result<RegisterEligibilityEntity>> checkPhone(
    RegisterRequestEntity request,
  ) => Result.guard(
    () =>
        _remoteDataSource.checkPhone(RegisterRequestModel.fromEntity(request)),
  );

  @override
  Future<Result<AuthSessionEntity>> login(LoginRequestEntity request) =>
      Result.guard(() async {
        final session = await _remoteDataSource.login(
          LoginRequestModel.fromEntity(
            request,
            client: await _localDataSource.clientInfo(),
          ),
        );
        return _signedIn(session, phone: request.phone);
      });

  @override
  Future<Result<PhoneVerificationEntity>> sendOtp(
    String phone, {
    int? resendToken,
    bool bySchool = false,
  }) => Result.guard(() async {
    if (_smsMisrFirst || bySchool) {
      try {
        return await _schoolOtp.sendCode(phone);
      } on AppException catch (error) {
        // SMS Misr failed: Firebase sends it instead — when the school
        // sends first; asked for the school's on purpose, its error stands.
        if (!_smsMisrFirst || !error.isSchoolSmsDown) rethrow;
        debugPrint('The school sent no code ($error): Firebase sends one.');
        return _phoneVerification.sendCode(phone, resendToken: resendToken);
      }
    }
    try {
      return await _phoneVerification.sendCode(phone, resendToken: resendToken);
    } on AppException catch (error) {
      // Firebase couldn't send it (blocked, out of quota, set up wrong…):
      // the school texts its own code instead. If that fails too, its
      // error is the one shown — it's the last word, and in the app's
      // language.
      debugPrint('Firebase sent no code ($error): the school sends one.');
      return _schoolOtp.sendCode(phone);
    }
  });

  @override
  Future<Result<String>> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) => Result.guard(
    () => _phoneVerification.verifyCode(
      verificationId: verificationId,
      smsCode: smsCode,
    ),
  );

  @override
  Future<Result<AuthSessionEntity>> completeRegistration(
    CompleteRegisterRequestEntity request,
  ) => Result.guard(() async {
    final session = await _remoteDataSource.completeRegistration(
      CompleteRegisterRequestModel.fromEntity(
        request,
        client: await _localDataSource.clientInfo(),
      ),
    );
    // Firebase only proved the number. The account exists either way, so a
    // failed sign-out is ignored.
    await _phoneVerification.signOut().catchError((Object _) {});
    // The parent logs in next, which keeps a token: this one isn't.
    return session;
  });

  @override
  Future<Result<void>> resetPassword(ResetPasswordRequestEntity request) =>
      Result.guard(() async {
        await _remoteDataSource.resetPassword(
          ResetPasswordRequestModel.fromEntity(request),
        );
        // As after signing up: Firebase only proved the number, and the
        // password is set either way.
        await _phoneVerification.signOut().catchError((Object _) {});
      });

  @override
  Future<Result<void>> changePassword(ChangePasswordRequestEntity request) =>
      Result.guard(
        () => _remoteDataSource.changePassword(
          ChangePasswordRequestModel.fromEntity(request),
        ),
      );

  @override
  Future<Result<SessionStatus>> checkSession() => Result.guard(() async {
    if (!await _localDataSource.hasToken()) return SessionStatus.none;
    try {
      await _remoteDataSource.checkSession();
      return SessionStatus.active;
    } on UnauthorizedException catch (exception) {
      await _forgetSession();
      return switch (exception) {
        UnauthorizedException(isAccountWithdrawn: true) =>
          SessionStatus.withdrawn,
        UnauthorizedException(isSessionReplaced: true) =>
          SessionStatus.replaced,
        _ => SessionStatus.ended,
      };
    }
  });

  @override
  Future<Result<void>> logout() => Result.guard(_forgetSession);

  @override
  Future<ParentEntity?> getSavedParent() => _localDataSource.getSavedParent();

  /// Keeps the session's token, so later requests send it, and its parent
  /// (with the [phone] logged in with, which the API masks) and children,
  /// so pages show them without calling the API.
  Future<AuthSessionEntity> _signedIn(
    AuthSessionModel session, {
    required String phone,
  }) async {
    await _localDataSource.saveToken(session.accessToken);
    await _localDataSource.saveParent(
      ParentModel.fromEntity(session.parent).withFullPhone(phone),
    );
    await _childrenLocalDataSource.saveChildren(session.children);
    return session;
  }

  Future<void> _forgetSession() async {
    _chatLocalDataSource.clear();
    await _localDataSource.clearToken();
    await _localDataSource.clearParent();
    await _childrenLocalDataSource.clearChildren();
  }
}
