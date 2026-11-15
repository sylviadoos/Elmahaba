import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';

/// A chat photo saved on the phone at [path], to show full screen.
class ChatImageFile {
  const ChatImageFile({required this.attachment, required this.path});

  final ChatAttachmentEntity attachment;
  final String path;
}

/// What the photo viewer opens with: a chat item's photos saved so far,
/// to swipe through, starting at the one tapped ([initialIndex]).
class ChatImagesArgs {
  const ChatImagesArgs({required this.images, required this.initialIndex});

  final List<ChatImageFile> images;
  final int initialIndex;
}
