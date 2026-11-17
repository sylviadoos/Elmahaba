import 'package:equatable/equatable.dart';

/// What happened after asking for the SMS code: from Firebase, or from the
/// school when Firebase couldn't send it.
sealed class PhoneVerificationEntity extends Equatable {
  const PhoneVerificationEntity();
}

/// The code was sent: check the one the parent types with [verificationId].
final class SmsCodeSent extends PhoneVerificationEntity {
  const SmsCodeSent({required this.verificationId, this.resendToken});

  final String verificationId;

  /// Pass it back to send the code again.
  final int? resendToken;

  @override
  List<Object?> get props => [verificationId, resendToken];
}

/// Firebase couldn't send it, so the school texted its own code (SMS
/// Misr). The typed code goes, as a `SchoolCodeProof`, with the request
/// that needs the number proved; the school checks it there.
final class SchoolCodeSent extends PhoneVerificationEntity {
  const SchoolCodeSent({required this.resendAfter});

  /// How long before the school sends another.
  final Duration resendAfter;

  @override
  List<Object?> get props => [resendAfter];
}

/// Android verified the number by itself — there's no code to type.
final class PhoneAutoVerified extends PhoneVerificationEntity {
  const PhoneAutoVerified({required this.firebaseIdToken});

  final String firebaseIdToken;

  @override
  List<Object?> get props => [firebaseIdToken];
}
