import 'package:al_mahhaba_school/features/auth/domain/entities/reset_password_request_entity.dart';

/// [ResetPasswordRequestEntity] as sent to `POST mobile/forgot-password`.
class ResetPasswordRequestModel extends ResetPasswordRequestEntity {
  const ResetPasswordRequestModel({
    required super.phone,
    required super.firebaseIdToken,
    required super.password,
    required super.passwordConfirmation,
  });

  factory ResetPasswordRequestModel.fromEntity(
    ResetPasswordRequestEntity entity,
  ) => ResetPasswordRequestModel(
    phone: entity.phone,
    firebaseIdToken: entity.firebaseIdToken,
    password: entity.password,
    passwordConfirmation: entity.passwordConfirmation,
  );

  Map<String, dynamic> toJson() => {
    'phone_number': phone,
    'firebase_id_token': firebaseIdToken,
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}
