import 'package:al_mahhaba_school/features/auth/data/models/client_info_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/phone_proof_json.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/complete_register_request_entity.dart';

/// [CompleteRegisterRequestEntity] as sent to `POST mobile/register/complete`.
class CompleteRegisterRequestModel extends CompleteRegisterRequestEntity {
  const CompleteRegisterRequestModel({
    required super.phone,
    required super.password,
    required super.proof,
    required this.client,
  });

  factory CompleteRegisterRequestModel.fromEntity(
    CompleteRegisterRequestEntity entity, {
    required ClientInfoModel client,
  }) => CompleteRegisterRequestModel(
    phone: entity.phone,
    password: entity.password,
    proof: entity.proof,
    client: client,
  );

  final ClientInfoModel client;

  /// The proof as `firebase_id_token`, or as `otp` for the school's code.
  Map<String, dynamic> toJson() => {
    'phone_number': phone,
    'password': password,
    ...proof.toJson(),
    ...client.toJson(),
  };
}
