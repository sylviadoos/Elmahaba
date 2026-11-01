import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/visitor_header.dart';
import 'package:al_mahhaba_school/core/widgets/visitor_page.dart';
import 'package:al_mahhaba_school/features/contact/presentation/view_model/contact_message_event.dart';
import 'package:al_mahhaba_school/features/contact/presentation/view_model/contact_message_view_model.dart';
import 'package:al_mahhaba_school/features/contact/presentation/widgets/contact_message_form.dart';
import 'package:al_mahhaba_school/features/contact/presentation/widgets/contact_message_sent.dart';

/// "Send us a message": a form that posts to the school.
class ContactMessagePage extends StatelessWidget {
  const ContactMessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider(
      create: (_) => getIt<ContactMessageViewModel>(),
      child: VisitorPage(
        header: VisitorHeader(
          title: l10n.sendUsAMessage,
          subtitle: l10n.sendMessageSubtitle,
        ),
        children: const [_ContactMessageBody()],
      ),
    );
  }
}

class _ContactMessageBody extends StatelessWidget {
  const _ContactMessageBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContactMessageViewModel, ContactMessageState>(
      listenWhen: (_, state) => state.state == StateType.error,
      listener: (context, state) {
        final exception = state.exception!;
        final invalidFields =
            exception is ServerException && exception.fieldErrors.isNotEmpty;
        context.showSnackBar(
          invalidFields
              ? context.l10n.checkHighlightedFields
              : exception.localizedMessage(context),
          isError: true,
        );
      },
      builder: (context, state) {
        if (state.state == StateType.success) {
          return const ContactMessageSent();
        }
        final exception = state.exception;
        return ContactMessageForm(
          isSending: state.state == StateType.loading,
          serverErrors: exception is ServerException
              ? exception.fieldErrors
              : const {},
          onSubmit: (message) => context
              .read<ContactMessageViewModel>()
              .doAction(SendContactMessageEvent(message)),
        );
      },
    );
  }
}
