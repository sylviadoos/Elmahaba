import 'package:equatable/equatable.dart';

/// Sets a new password once Firebase verified the parent's mobile.
class ResetPasswordRequestEntity extends Equatable {
  const ResetPasswordRequestEntity({
    required this.phone,
    required this.firebaseIdToken,
    required this.password,
    required this.passwordConfirmation,
  });

  /// Local Egyptian mobile, e.g. "01201234154" — the one that was verified.
  final String phone;

  /// Proof from Firebase that the parent owns [phone].
  final String firebaseIdToken;
  final String password;
  final String passwordConfirmation;

  @override
  List<Object?> get props => [
    phone,
    firebaseIdToken,
    password,
    passwordConfirmation,
  ];
}
