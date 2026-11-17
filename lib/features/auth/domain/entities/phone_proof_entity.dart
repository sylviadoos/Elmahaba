import 'package:equatable/equatable.dart';

/// What proves the parent owns their mobile, sent with the new account or
/// the new password: Firebase's sign-in, or — when Firebase couldn't send
/// its SMS — the code the school sent instead (SMS Misr).
sealed class PhoneProofEntity extends Equatable {
  const PhoneProofEntity();
}

/// Firebase checked the code (or Android verified the number by itself).
final class FirebaseProof extends PhoneProofEntity {
  const FirebaseProof(this.idToken);

  /// Firebase's ID token for the verified number.
  final String idToken;

  @override
  List<Object?> get props => [idToken];
}

/// The code the school texted, as the parent typed it. Not checked by the
/// app: the school checks it with the request it's sent with.
final class SchoolCodeProof extends PhoneProofEntity {
  const SchoolCodeProof(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}
