import 'package:al_mahhaba_school/features/app_version/data/models/app_version_model.dart';

/// The API's example: 2.1.0 out, 2.0.0 still fine.
const optional = AppVersionModel(
  updateAvailable: true,
  forceUpdate: false,
  latestVersion: '2.1.0',
  minimumSupportedVersion: '2.0.0',
  message: 'يتوفر إصدار جديد من التطبيق...',
  storeUrl:
      'https://play.google.com/store/apps/details?id=com.almahabbahschools.parents',
);

/// The installed version is below the minimum.
const forced = AppVersionModel(
  updateAvailable: true,
  forceUpdate: true,
  latestVersion: '2.1.0',
  minimumSupportedVersion: '2.1.0',
  message: 'لازم تحدّث التطبيق',
  storeUrl:
      'https://play.google.com/store/apps/details?id=com.almahabbahschools.parents',
);

const upToDate = AppVersionModel(updateAvailable: false, forceUpdate: false);
