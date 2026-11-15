import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_intent.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_image_loads.dart';
import 'package:al_mahhaba_school/features/chat/presentation/chat_image_source.dart';

/// The announcements' photos, from the [AnnouncementsBloc].
class AnnouncementImageSource implements ChatImageSource {
  const AnnouncementImageSource();

  @override
  BaseState<String>? watch(BuildContext context, int id) =>
      context.select((AnnouncementsBloc bloc) => bloc.state.images[id]);

  @override
  ChatImages saved(BuildContext context) =>
      context.read<AnnouncementsBloc>().state.images;

  @override
  void load(BuildContext context, ChatAttachmentEntity attachment) => context
      .read<AnnouncementsBloc>()
      .add(LoadAnnouncementImageIntent(attachment));
}
