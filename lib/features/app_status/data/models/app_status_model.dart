import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/app_status/domain/entities/app_status_entity.dart';

class AppStatusModel extends AppStatusEntity {
  const AppStatusModel({required super.enabled, super.message});

  /// { "enabled": true, "message": null } — not saying is not enabled.
  factory AppStatusModel.fromJson(Map<String, dynamic> json) => AppStatusModel(
    enabled: json['enabled'] == true,
    message: jsonTextOrNull(json['message']),
  );
}
