import 'package:equatable/equatable.dart';

/// What the school says of the app now: whether parents can log in.
class AppStatusEntity extends Equatable {
  const AppStatusEntity({required this.enabled, this.message});

  /// False: parents can't log in for now, so visitors get no "Log in".
  final bool enabled;

  /// What the school says about it, if anything.
  final String? message;

  @override
  List<Object?> get props => [enabled, message];
}
