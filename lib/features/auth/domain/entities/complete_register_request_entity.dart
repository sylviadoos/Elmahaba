import 'package:equatable/equatable.dart';

/// Creates the parent's account once Firebase verified their mobile.
class CompleteRegisterRequestEntity extends Equatable {
  const CompleteRegisterRequestEntity({
    required this.phone,
    required this.password,
    required this.firebaseIdToken,
  });

  /// Local Egyptian mobile, e.g. "01201234154" — the one that was verified.
  final String phone;
  final String password;

  /// Proof from Firebase that the parent owns [phone].
  final String firebaseIdToken;

  @override
  List<Object?> get props => [phone, password, firebaseIdToken];
}
