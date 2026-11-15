import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_image_loads.dart';
import 'package:al_mahhaba_school/features/chat/presentation/chat_image_source.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/extensions/excuse_document_attachment.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/excuse_details_event.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/excuse_details_view_model.dart';

/// An excuse's documents' pictures, from the [ExcuseDetailsViewModel].
class ExcuseImageSource implements ChatImageSource {
  const ExcuseImageSource();

  @override
  BaseState<String>? watch(BuildContext context, int id) =>
      context.select((ExcuseDetailsViewModel model) => model.state.images[id]);

  @override
  ChatImages saved(BuildContext context) =>
      context.read<ExcuseDetailsViewModel>().state.images;

  @override
  void load(BuildContext context, ChatAttachmentEntity attachment) => context
      .read<ExcuseDetailsViewModel>()
      .doAction(LoadExcuseImageEvent(attachment.asExcuseDocument));
}
