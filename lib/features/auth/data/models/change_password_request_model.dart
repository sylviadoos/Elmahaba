import 'package:al_mahhaba_school/features/auth/domain/entities/change_password_request_entity.dart';

/// [ChangePasswordRequestEntity] as sent to
/// `POST v1/parent/auth/change-password`.
class ChangePasswordRequestModel extends ChangePasswordRequestEntity {
  const ChangePasswordRequestModel({
    required super.currentPassword,
    required super.password,
    required super.passwordConfirmation,
  });

  factory ChangePasswordRequestModel.fromEntity(
    ChangePasswordRequestEntity entity,
  ) => ChangePasswordRequestModel(
    currentPassword: entity.currentPassword,
    password: entity.password,
    passwordConfirmation: entity.passwordConfirmation,
  );

  Map<String, dynamic> toJson() => {
    'current_password': currentPassword,
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}
