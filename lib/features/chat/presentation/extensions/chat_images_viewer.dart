import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_image_loads.dart';
import 'package:al_mahhaba_school/features/chat/presentation/chat_images_args.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/picked_attachment.dart';

extension ChatImagesViewer on BuildContext {
  /// [tapped] full screen, with the other [images] of its item that are
  /// [saved] so far beside it. Nothing while [tapped] isn't saved.
  void openChatImages(
    List<ChatAttachmentEntity> images, {
    required ChatImages saved,
    required ChatAttachmentEntity tapped,
  }) {
    final files = [
      for (final attachment in images)
        if (saved[attachment.id] case BaseState(
          state: StateType.success,
          data: final String path,
        ))
          ChatImageFile(attachment: attachment, path: path),
    ];
    final index = files.indexWhere((file) => file.attachment.id == tapped.id);
    if (index < 0) return;
    showChatImages(ChatImagesArgs(images: files, initialIndex: index));
  }

  /// The photos in [args] full screen.
  void showChatImages(ChatImagesArgs args) =>
      push(AppRoutes.chatImages, extra: args);

  /// The photos [picked] to send full screen, from [tapped], before
  /// they're sent. Not sent yet, they have no id: each goes by its place,
  /// below zero so none is taken for one already sent.
  void previewPickedPhotos(
    List<PickedAttachment> picked,
    PickedAttachment tapped,
  ) {
    final photos = [
      for (final (index, file) in picked.indexed)
        if (file.isImage)
          ChatImageFile(
            attachment: ChatAttachmentEntity(
              id: -(index + 1),
              fileName: file.name,
              mimeType: 'image/${file.extension}',
              size: file.size,
              isAvailable: true,
            ),
            path: file.path,
          ),
    ];
    final index = photos.indexWhere((photo) => photo.path == tapped.path);
    if (index < 0) return;
    showChatImages(ChatImagesArgs(images: photos, initialIndex: index));
  }
}
