import 'package:al_mahhaba_school/features/contact/domain/entities/contact_message_entity.dart';

sealed class ContactMessageEvent {
  const ContactMessageEvent();
}

/// Sends the filled-in form.
final class SendContactMessageEvent extends ContactMessageEvent {
  const SendContactMessageEvent(this.message);

  final ContactMessageEntity message;
}
