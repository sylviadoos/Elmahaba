import 'package:al_mahhaba_school/features/children/domain/entities/link_verification_entity.dart';

sealed class LinkChildCodeEvent {
  const LinkChildCodeEvent();
}

/// Checks the [code] the parent entered, for the check [token].
final class CheckLinkCodeEvent extends LinkChildCodeEvent {
  const CheckLinkCodeEvent({required this.token, required this.code});

  final String token;
  final String code;
}

/// Sends the code of [verification] — by Firebase when the school gave its
/// number for the child, else (or when Firebase can't) by the school. The
/// first time, and again.
final class SendLinkCodeEvent extends LinkChildCodeEvent {
  const SendLinkCodeEvent(this.verification);

  final LinkVerificationEntity verification;
}
