import 'package:al_mahhaba_school/features/auth/data/models/client_info_model.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/login_request_entity.dart';

/// [LoginRequestEntity] as sent to `POST mobile/login`.
class LoginRequestModel extends LoginRequestEntity {
  const LoginRequestModel({
    required super.phone,
    required super.password,
    required this.client,
  });

  factory LoginRequestModel.fromEntity(
    LoginRequestEntity entity, {
    required ClientInfoModel client,
  }) => LoginRequestModel(
    phone: entity.phone,
    password: entity.password,
    client: client,
  );

  final ClientInfoModel client;

  Map<String, dynamic> toJson() => {
    'phone_number': phone,
    'password': password,
    ...client.toJson(),
  };
}
