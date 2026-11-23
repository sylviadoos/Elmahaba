import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/app_version/domain/entities/app_version_entity.dart';

class AppVersionModel extends AppVersionEntity {
  const AppVersionModel({
    required super.updateAvailable,
    required super.forceUpdate,
    super.latestVersion,
    super.minimumSupportedVersion,
    super.message,
    super.storeUrl,
  });

  /// The `data` of `GET v1/parent/app-version`:
  /// { "update_available": true, "force_update": false,
  ///   "latest_version": "2.1.0", "minimum_supported_version": "2.0.0",
  ///   "message": "…", "store_url": "https://play.google.com/…" }
  ///
  /// A forced update is an update, whatever `update_available` says.
  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    final force = jsonBool(json['force_update']) ?? false;
    return AppVersionModel(
      updateAvailable: force || (jsonBool(json['update_available']) ?? false),
      forceUpdate: force,
      latestVersion: jsonText(json['latest_version']),
      minimumSupportedVersion: jsonText(json['minimum_supported_version']),
      // As written: line breaks kept.
      message: (json['message'] as String? ?? '').trim(),
      storeUrl: jsonText(json['store_url']),
    );
  }

  factory AppVersionModel.fromEntity(AppVersionEntity entity) =>
      AppVersionModel(
        updateAvailable: entity.updateAvailable,
        forceUpdate: entity.forceUpdate,
        latestVersion: entity.latestVersion,
        minimumSupportedVersion: entity.minimumSupportedVersion,
        message: entity.message,
        storeUrl: entity.storeUrl,
      );

  /// As the API sends it, to keep on the phone.
  Map<String, dynamic> toJson() => {
    'update_available': updateAvailable,
    'force_update': forceUpdate,
    'latest_version': latestVersion,
    'minimum_supported_version': minimumSupportedVersion,
    'message': message,
    'store_url': storeUrl,
  };

  /// These, with [url] as the store page.
  AppVersionModel withStoreUrl(String url) => AppVersionModel(
    updateAvailable: updateAvailable,
    forceUpdate: forceUpdate,
    latestVersion: latestVersion,
    minimumSupportedVersion: minimumSupportedVersion,
    message: message,
    storeUrl: url,
  );
}
