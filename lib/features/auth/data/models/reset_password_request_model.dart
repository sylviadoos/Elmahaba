import 'package:al_mahhaba_school/features/auth/data/models/phone_proof_json.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/reset_password_request_entity.dart';

/// [ResetPasswordRequestEntity] as sent to `POST mobile/forgot-password`.
class ResetPasswordRequestModel extends ResetPasswordRequestEntity {
  const ResetPasswordRequestModel({
    required super.phone,
    required super.proof,
    required super.password,
    required super.passwordConfirmation,
  });

  factory ResetPasswordRequestModel.fromEntity(
    ResetPasswordRequestEntity entity,
  ) => ResetPasswordRequestModel(
    phone: entity.phone,
    proof: entity.proof,
    password: entity.password,
    passwordConfirmation: entity.passwordConfirmation,
  );

  /// The proof as `firebase_id_token`, or as `otp` for the school's code.
  Map<String, dynamic> toJson() => {
    'phone_number': phone,
    ...proof.toJson(),
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}
