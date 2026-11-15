import 'package:equatable/equatable.dart';

/// A code the school texted to the phone it has for the child, to prove the
/// parent may link them (the parent's own number is another one). Sent by
/// the school's SMS, not Firebase.
class LinkVerificationEntity extends Equatable {
  const LinkVerificationEntity({
    required this.token,
    required this.maskedPhone,
    required this.relationship,
    required this.expiresIn,
    required this.resendAfter,
    required this.resendsLeft,
  });

  /// Names this check: sent back with the code, or to resend it.
  final String token;

  /// The school's number for the child, hidden but its end, e.g.
  /// "••• ••• 4567": shown as it is; the whole number never comes.
  final String maskedPhone;

  /// e.g. "father".
  final String relationship;

  /// How long the code works, from when it was sent.
  final Duration expiresIn;

  /// How long until another code can be asked for.
  final Duration resendAfter;

  /// How many more codes can be asked for.
  final int resendsLeft;

  @override
  List<Object?> get props => [
    token,
    maskedPhone,
    relationship,
    expiresIn,
    resendAfter,
    resendsLeft,
  ];
}
