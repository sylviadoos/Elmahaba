import 'package:equatable/equatable.dart';

/// What happened after asking Firebase to send the SMS code.
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

/// Android verified the number by itself — there's no code to type.
final class PhoneAutoVerified extends PhoneVerificationEntity {
  const PhoneAutoVerified({required this.firebaseIdToken});

  final String firebaseIdToken;

  @override
  List<Object?> get props => [firebaseIdToken];
}
