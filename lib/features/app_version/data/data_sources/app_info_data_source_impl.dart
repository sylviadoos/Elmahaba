import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:al_mahhaba_school/features/app_version/data/data_sources/app_info_data_source.dart';

@LazySingleton(as: AppInfoDataSource)
class AppInfoDataSourceImpl implements AppInfoDataSource {
  @override
  Future<String> version() async => (await PackageInfo.fromPlatform()).version;

  @override
  String? get platform {
    if (kIsWeb) return null;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => null,
    };
  }
}
