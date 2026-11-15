import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/data/data_sources/phone_verification_data_source.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';

@LazySingleton(as: PhoneVerificationDataSource)
class PhoneVerificationDataSourceImpl implements PhoneVerificationDataSource {
  PhoneVerificationDataSourceImpl(this._auth);

  final FirebaseAuth _auth;

  @override
  Future<PhoneVerificationEntity> sendCode(String phone, {int? resendToken}) {
    final result = Completer<PhoneVerificationEntity>();
    final phoneNumber = _international(phone);
    _log(
      'Sending a code to $phoneNumber${resendToken != null ? ' again' : ''}',
    );

    void fail(Object error) {
      if (!result.isCompleted) result.completeError(_handle(error));
    }

    _auth
        .verifyPhoneNumber(
          phoneNumber: phoneNumber,
          forceResendingToken: resendToken,
          codeSent: (verificationId, resendToken) {
            if (result.isCompleted) return;
            _log('Code sent');
            result.complete(
              SmsCodeSent(
                verificationId: verificationId,
                resendToken: resendToken,
              ),
            );
          },
          // Before the code is sent: the number was verified without one.
          // After: Android read the SMS itself — the parent types it anyway.
          verificationCompleted: (credential) async {
            if (result.isCompleted) return;
            try {
              final token = await _signIn(credential);
              _log('Number verified without a code');
              if (!result.isCompleted) {
                result.complete(PhoneAutoVerified(firebaseIdToken: token));
              }
            } catch (e) {
              fail(e);
            }
          },
          verificationFailed: fail,
          codeAutoRetrievalTimeout: (_) {},
        )
        .catchError(fail);

    return result.future;
  }

  @override
  Future<String> verifyCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final token = await _signIn(
        PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        ),
      );
      _log('Code accepted');
      return token;
    } catch (e) {
      throw _handle(e);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  /// Signs in to Firebase and returns the ID token that proves the number.
  Future<String> _signIn(PhoneAuthCredential credential) async {
    final signIn = await _auth.signInWithCredential(credential);
    final token = await signIn.user?.getIdToken();
    if (token == null) throw const UnknownException();
    return token;
  }

  /// "01201234154" → "+201201234154" (the format Firebase needs).
  static String _international(String phone) => '+20${phone.substring(1)}';

  static AppException _handle(Object error) {
    // Firebase's message explains setup problems (missing SHA, Phone sign-in
    // turned off…), so it's logged even though it's never shown.
    _log(
      'Failed: ${error is FirebaseAuthException ? '${error.code} — ${error.message}' : error}',
    );
    return switch (error) {
      AppException() => error,
      FirebaseAuthException(code: 'network-request-failed') =>
        const NetworkException(),
      FirebaseAuthException(:final code) => PhoneVerificationException(
        code: code,
      ),
      _ => const UnknownException(),
    };
  }

  /// Firebase calls don't go through Dio, so they're logged here, like
  /// `ApiLogInterceptor` does for the API.
  static void _log(String message) {
    if (AppConfig.enableLogging) debugPrint('[firebase] $message');
  }
}
