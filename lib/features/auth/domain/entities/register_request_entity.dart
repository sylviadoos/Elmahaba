import 'package:equatable/equatable.dart';

/// What a parent fills in on the Register page.
class RegisterRequestEntity extends Equatable {
  const RegisterRequestEntity({
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  /// Local Egyptian mobile, e.g. "01201234154".
  final String phone;
  final String password;
  final String passwordConfirmation;

  @override
  List<Object?> get props => [phone, password, passwordConfirmation];
}
