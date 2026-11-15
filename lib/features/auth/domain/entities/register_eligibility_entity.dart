import 'package:equatable/equatable.dart';

/// Whether a mobile number can sign up — it must be a parent's number in
/// the school records, with no account yet.
class RegisterEligibilityEntity extends Equatable {
  const RegisterEligibilityEntity({
    required this.phoneMasked,
    required this.eligible,
    required this.alreadyRegistered,
  });

  /// The number with its middle hidden, e.g. "0120****154" — shown on the
  /// OTP page.
  final String phoneMasked;
  final bool eligible;
  final bool alreadyRegistered;

  @override
  List<Object?> get props => [phoneMasked, eligible, alreadyRegistered];
}
