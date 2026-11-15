import 'package:flutter/widgets.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_image_loads.dart';

/// Where a page's photos come from — its bloc (the chat's, Homework's):
/// each photo as it loads, the ones saved so far, and asking for one.
abstract interface class ChatImageSource {
  /// The photo with attachment [id]: where it's saved, loading, or why it
  /// didn't load; null before it's asked for. Rebuilds the widget as it
  /// loads, so it's called while building it.
  BaseState<String>? watch(BuildContext context, int id);

  /// The photos saved so far.
  ChatImages saved(BuildContext context);

  /// Asks for [attachment]'s photo (nothing when it's saved or on its way).
  void load(BuildContext context, ChatAttachmentEntity attachment);
}
