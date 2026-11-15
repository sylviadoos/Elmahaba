import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';

/// The photo types the app draws itself: shown in the chat, the others are
/// files to open.
const Set<String> _drawnTypes = {
  'image/jpeg',
  'image/jpg',
  'image/pjpeg',
  'image/png',
  'image/gif',
  'image/webp',
  'image/bmp',
};

extension ChatAttachmentKind on ChatAttachmentEntity {
  /// A photo, shown in the chat and full screen rather than as a file.
  bool get isImage => _drawnTypes.contains(mimeType.toLowerCase());

  /// A PDF: its first page shows in place of it, and it opens here, full
  /// screen.
  bool get isPdf =>
      mimeType.toLowerCase() == 'application/pdf' || typeLabel == 'PDF';

  /// "PDF", "DOCX": the end of its name, else of its type, up to 4
  /// letters; empty when neither says.
  String get typeLabel {
    final dot = fileName.lastIndexOf('.');
    final fromName = dot >= 0 ? fileName.substring(dot + 1) : '';
    final label = (fromName.isNotEmpty ? fromName : mimeType.split('/').last)
        .toUpperCase();
    return label.length > 4 ? label.substring(0, 4) : label;
  }

  /// The photo flies from the chat to full screen, and back.
  String get heroTag => 'chat-image-$id';
}
