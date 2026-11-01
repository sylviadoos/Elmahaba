import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/contact/domain/entities/contact_message_entity.dart';
import 'package:al_mahhaba_school/features/contact/domain/use_cases/send_contact_message_use_case.dart';
import 'package:al_mahhaba_school/features/contact/presentation/view_model/contact_message_event.dart';

/// Success carries no data: the page just shows "Message sent!".
typedef ContactMessageState = BaseState<void>;

/// Drives the "Send us a message" page. No navigation actions, hence `void`.
@injectable
class ContactMessageViewModel
    extends BaseCubit<ContactMessageState, ContactMessageEvent, void> {
  ContactMessageViewModel(this._sendMessage)
    : super(const ContactMessageState.initial());

  final SendContactMessageUseCase _sendMessage;

  @override
  Future<void> doAction(ContactMessageEvent event) async {
    switch (event) {
      case SendContactMessageEvent(:final message):
        await _send(message);
    }
  }

  Future<void> _send(ContactMessageEntity message) async {
    if (state.state == StateType.loading) return;
    emit(const ContactMessageState.loading());
    final result = await _sendMessage(message);
    if (isClosed) return;
    emit(
      result.when(
        success: (_) => const ContactMessageState.success(null),
        failure: (exception) => ContactMessageState.error(exception),
      ),
    );
  }
}
