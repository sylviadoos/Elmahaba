import 'package:al_mahhaba_school/features/auth/domain/entities/change_password_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/login_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/register_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/reset_password_request_entity.dart';

sealed class AuthEvent {
  const AuthEvent();
}

/// Checks the filled-in mobile can sign up.
final class CheckRegisterPhoneEvent extends AuthEvent {
  const CheckRegisterPhoneEvent(this.request);

  final RegisterRequestEntity request;
}

/// Signs in with the filled-in mobile and password.
final class LoginEvent extends AuthEvent {
  const LoginEvent(this.request);

  final LoginRequestEntity request;
}

/// Sends the SMS code to [request]'s mobile — again, after the first time.
final class SendOtpEvent extends AuthEvent {
  const SendOtpEvent(this.request);

  final RegisterRequestEntity request;
}

/// Checks the typed [code], then creates the account from [request].
final class VerifyOtpEvent extends AuthEvent {
  const VerifyOtpEvent(this.request, this.code);

  final RegisterRequestEntity request;
  final String code;
}

/// Forgot password: sends the SMS code to [phone] — again, after the first
/// time.
final class SendResetCodeEvent extends AuthEvent {
  const SendResetCodeEvent(this.phone);

  final String phone;
}

/// Forgot password: checks the typed [code]; Firebase's proof of the
/// number comes back in `PhoneVerified`.
final class VerifyResetCodeEvent extends AuthEvent {
  const VerifyResetCodeEvent(this.code);

  final String code;
}

/// Forgot password: sets the new password for the verified number.
final class ResetPasswordEvent extends AuthEvent {
  const ResetPasswordEvent(this.request);

  final ResetPasswordRequestEntity request;
}

/// Profile: changes the signed-in parent's password.
final class ChangePasswordEvent extends AuthEvent {
  const ChangePasswordEvent(this.request);

  final ChangePasswordRequestEntity request;
}
