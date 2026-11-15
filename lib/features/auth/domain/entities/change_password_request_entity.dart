import 'package:equatable/equatable.dart';

/// Changes the signed-in parent's password.
class ChangePasswordRequestEntity extends Equatable {
  const ChangePasswordRequestEntity({
    required this.currentPassword,
    required this.password,
    required this.passwordConfirmation,
  });

  final String currentPassword;
  final String password;
  final String passwordConfirmation;

  @override
  List<Object?> get props => [currentPassword, password, passwordConfirmation];
}
