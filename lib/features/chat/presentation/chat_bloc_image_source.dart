import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_image_loads.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_intent.dart';
import 'package:al_mahhaba_school/features/chat/presentation/chat_image_source.dart';

/// The chat's photos, from the [ChatBloc].
class ChatBlocImageSource implements ChatImageSource {
  const ChatBlocImageSource();

  @override
  BaseState<String>? watch(BuildContext context, int id) =>
      context.select((ChatBloc bloc) => bloc.state.images[id]);

  @override
  ChatImages saved(BuildContext context) =>
      context.read<ChatBloc>().state.images;

  @override
  void load(BuildContext context, ChatAttachmentEntity attachment) =>
      context.read<ChatBloc>().add(LoadImageIntent(attachment));
}
