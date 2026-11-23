import 'package:equatable/equatable.dart';

/// What the school says about the version installed on this phone: whether
/// a newer one is out, and whether it must be installed before the app can
/// be used.
class AppVersionEntity extends Equatable {
  const AppVersionEntity({
    required this.updateAvailable,
    required this.forceUpdate,
    this.latestVersion = '',
    this.minimumSupportedVersion = '',
    this.message = '',
    this.storeUrl = '',
  });

  /// Nothing to install.
  static const AppVersionEntity upToDate = AppVersionEntity(
    updateAvailable: false,
    forceUpdate: false,
  );

  final bool updateAvailable;

  /// The app can't be used until it's updated.
  final bool forceUpdate;

  /// e.g. "2.1.0".
  final String latestVersion;
  final String minimumSupportedVersion;

  /// What the parent is told, in the school's words; empty for the app's.
  final String message;

  /// The store page for this phone (Google Play or the App Store).
  final String storeUrl;

  @override
  List<Object?> get props => [
    updateAvailable,
    forceUpdate,
    latestVersion,
    minimumSupportedVersion,
    message,
    storeUrl,
  ];
}
