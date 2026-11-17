import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/auth/domain/entities/phone_proof_entity.dart';

/// Creates the parent's account once their mobile is verified.
class CompleteRegisterRequestEntity extends Equatable {
  const CompleteRegisterRequestEntity({
    required this.phone,
    required this.password,
    required this.proof,
  });

  /// Local Egyptian mobile, e.g. "01201234154" — the one that was verified.
  final String phone;
  final String password;

  /// That the parent owns [phone].
  final PhoneProofEntity proof;

  @override
  List<Object?> get props => [phone, password, proof];
}
