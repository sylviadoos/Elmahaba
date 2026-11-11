import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/repos/chat_repo.dart';

/// A chat PDF's first page as a picture saved on the phone, to show in
/// place of the file, [cancel] stopping it:
/// `final result = await previewChatAttachment(attachment);`
@lazySingleton
class PreviewChatAttachmentUseCase {
  PreviewChatAttachmentUseCase(this._repo);

  final ChatRepo _repo;

  Future<Result<String>> call(
    ChatAttachmentEntity attachment, {
    CancelHandle? cancel,
  }) => _repo.previewAttachment(attachment, cancel: cancel);
}
