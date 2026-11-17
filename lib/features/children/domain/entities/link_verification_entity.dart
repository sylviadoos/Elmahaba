import 'package:equatable/equatable.dart';

/// A code sent to the phone the school has for the child, to prove the
/// parent may link them (the parent's own number is another one). By
/// Firebase when the school gives the whole [phone], and by the school's
/// own SMS (SMS Misr) when it doesn't, or when Firebase can't send it.
class LinkVerificationEntity extends Equatable {
  const LinkVerificationEntity({
    required this.token,
    required this.maskedPhone,
    required this.relationship,
    required this.expiresIn,
    required this.resendAfter,
    required this.resendsLeft,
    this.phone,
  });

  /// Names this check: sent back with the code, or to resend it.
  final String token;

  /// The school's number for the child, hidden but its end, e.g.
  /// "••• ••• 4567": shown as it is.
  final String maskedPhone;

  /// e.g. "father".
  final String relationship;

  /// How long the code works, from when it was sent.
  final Duration expiresIn;

  /// How long until another code can be asked for.
  final Duration resendAfter;

  /// How many more codes the school can text.
  final int resendsLeft;

  /// The school's number for the child, whole and local ("01012345678"),
  /// for Firebase to send the code to: the school hasn't texted one yet.
  /// Null when it has (by its own SMS). Never shown.
  final String? phone;

  @override
  List<Object?> get props => [
    token,
    maskedPhone,
    relationship,
    expiresIn,
    resendAfter,
    resendsLeft,
    phone,
  ];
}
