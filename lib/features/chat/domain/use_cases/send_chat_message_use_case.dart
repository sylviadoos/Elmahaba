import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/new_chat_message_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/repos/chat_repo.dart';

/// Sends the parent's message to the school, [onProgress] following its
/// files' upload, [cancel] stopping it:
/// `final result = await sendChatMessage(message);`
@lazySingleton
class SendChatMessageUseCase {
  SendChatMessageUseCase(this._repo);

  final ChatRepo _repo;

  Future<Result<ChatItemEntity>> call(
    NewChatMessageEntity message, {
    UploadProgressCallback? onProgress,
    CancelHandle? cancel,
  }) => _repo.sendMessage(message, onProgress: onProgress, cancel: cancel);
}
