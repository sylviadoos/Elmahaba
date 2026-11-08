import 'package:al_mahhaba_school/features/auth/domain/entities/register_request_entity.dart';

/// [RegisterRequestEntity] as sent to `POST mobile/register/check-phone`.
class RegisterRequestModel extends RegisterRequestEntity {
  const RegisterRequestModel({
    required super.phone,
    required super.password,
    required super.passwordConfirmation,
  });

  factory RegisterRequestModel.fromEntity(RegisterRequestEntity entity) =>
      RegisterRequestModel(
        phone: entity.phone,
        password: entity.password,
        passwordConfirmation: entity.passwordConfirmation,
      );

  Map<String, dynamic> toJson() => {
    'phone_number': phone,
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}
