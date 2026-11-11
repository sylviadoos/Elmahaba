import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_image_loads.dart';
import 'package:al_mahhaba_school/features/chat/presentation/chat_image_source.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_bloc.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_intent.dart';

/// The homework's photos, from the [HomeworkBloc].
class HomeworkImageSource implements ChatImageSource {
  const HomeworkImageSource();

  @override
  BaseState<String>? watch(BuildContext context, int id) =>
      context.select((HomeworkBloc bloc) => bloc.state.images[id]);

  @override
  ChatImages saved(BuildContext context) =>
      context.read<HomeworkBloc>().state.images;

  @override
  void load(BuildContext context, ChatAttachmentEntity attachment) =>
      context.read<HomeworkBloc>().add(LoadHomeworkImageIntent(attachment));
}
