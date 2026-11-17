import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/auth/domain/entities/phone_proof_entity.dart';

/// Sets a new password once the parent's mobile is verified.
class ResetPasswordRequestEntity extends Equatable {
  const ResetPasswordRequestEntity({
    required this.phone,
    required this.proof,
    required this.password,
    required this.passwordConfirmation,
  });

  /// Local Egyptian mobile, e.g. "01201234154" — the one that was verified.
  final String phone;

  /// That the parent owns [phone].
  final PhoneProofEntity proof;
  final String password;
  final String passwordConfirmation;

  @override
  List<Object?> get props => [phone, proof, password, passwordConfirmation];
}
