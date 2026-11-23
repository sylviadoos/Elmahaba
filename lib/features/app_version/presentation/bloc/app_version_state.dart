import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/app_version/domain/entities/app_version_entity.dart';

/// What the app shows about its version, on top of everything.
sealed class AppVersionState extends Equatable {
  const AppVersionState();
}

/// Nothing: the app as usual.
final class NoUpdateState extends AppVersionState {
  const NoUpdateState();

  @override
  List<Object?> get props => [];
}

/// A newer version is out: "Update" or "Later".
final class OptionalUpdateState extends AppVersionState {
  const OptionalUpdateState(this.update);

  final AppVersionEntity update;

  @override
  List<Object?> get props => [update];
}

/// The app can't be used until it's updated: "Update" only, and it stays.
final class ForcedUpdateState extends AppVersionState {
  const ForcedUpdateState(this.update);

  final AppVersionEntity update;

  @override
  List<Object?> get props => [update];
}
