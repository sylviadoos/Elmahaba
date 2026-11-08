import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/repos/chat_repo.dart';

/// Saves a chat file on the phone, to open it, [cancel] stopping it:
/// `final result = await downloadChatAttachment(attachment);`
@lazySingleton
class DownloadChatAttachmentUseCase {
  DownloadChatAttachmentUseCase(this._repo);

  final ChatRepo _repo;

  Future<Result<String>> call(
    ChatAttachmentEntity attachment, {
    CancelHandle? cancel,
  }) => _repo.downloadAttachment(attachment, cancel: cancel);
}
