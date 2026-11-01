sealed class ContactEvent {
  const ContactEvent();
}

/// Loads the contact details — when the page opens and on "Try again".
final class GetContactInfoEvent extends ContactEvent {
  const GetContactInfoEvent();
}
