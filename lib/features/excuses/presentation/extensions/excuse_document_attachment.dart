import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_document_entity.dart';

extension ExcuseDocumentAttachment on ExcuseDocumentEntity {
  /// The document as the chat's files are, to show it the same way (a
  /// photo, a PDF's first page, opened full screen).
  ChatAttachmentEntity get asAttachment => ChatAttachmentEntity(
    id: id,
    fileName: fileName,
    mimeType: mimeType,
    size: size,
    isAvailable: isAvailable,
  );
}

extension AttachmentExcuseDocument on ChatAttachmentEntity {
  /// Back from [ExcuseDocumentAttachment.asAttachment], to ask for it.
  ExcuseDocumentEntity get asExcuseDocument => ExcuseDocumentEntity(
    id: id,
    fileName: fileName,
    mimeType: mimeType,
    size: size,
    isAvailable: isAvailable,
  );
}
