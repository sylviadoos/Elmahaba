sealed class LinkChildCodeEvent {
  const LinkChildCodeEvent();
}

/// Checks the [code] the parent entered, for the check [token].
final class CheckLinkCodeEvent extends LinkChildCodeEvent {
  const CheckLinkCodeEvent({required this.token, required this.code});

  final String token;
  final String code;
}

/// Asks the school to text the code of the check [token] again.
final class ResendLinkCodeEvent extends LinkChildCodeEvent {
  const ResendLinkCodeEvent(this.token);

  final String token;
}
