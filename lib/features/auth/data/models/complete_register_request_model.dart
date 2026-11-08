import 'package:al_mahhaba_school/features/auth/data/models/client_info_model.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/complete_register_request_entity.dart';

/// [CompleteRegisterRequestEntity] as sent to `POST mobile/register/complete`.
class CompleteRegisterRequestModel extends CompleteRegisterRequestEntity {
  const CompleteRegisterRequestModel({
    required super.phone,
    required super.password,
    required super.firebaseIdToken,
    required this.client,
  });

  factory CompleteRegisterRequestModel.fromEntity(
    CompleteRegisterRequestEntity entity, {
    required ClientInfoModel client,
  }) => CompleteRegisterRequestModel(
    phone: entity.phone,
    password: entity.password,
    firebaseIdToken: entity.firebaseIdToken,
    client: client,
  );

  final ClientInfoModel client;

  Map<String, dynamic> toJson() => {
    'phone_number': phone,
    'password': password,
    'firebase_id_token': firebaseIdToken,
    ...client.toJson(),
  };
}
