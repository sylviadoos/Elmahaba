import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_local_data_source.dart';
import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:al_mahhaba_school/features/chat/data/models/new_chat_message_model.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_page_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/new_chat_message_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/repos/chat_repo.dart';

@LazySingleton(as: ChatRepo)
class ChatRepoImpl implements ChatRepo {
  ChatRepoImpl(this._remoteDataSource, this._localDataSource);

  final ChatRemoteDataSource _remoteDataSource;
  final ChatLocalDataSource _localDataSource;

  @override
  Future<Result<ChatPageEntity>> getChat({
    int? studentId,
    String? before,
    CancelHandle? cancel,
  }) => Result.guard(() async {
    final page = await _remoteDataSource.getChat(
      studentId: studentId,
      before: before,
      cancel: cancel,
    );
    if (before == null) _localDataSource.saveNewestPage(studentId, page);
    return page;
  });

  @override
  ChatPageEntity? cachedChat(int? studentId) =>
      _localDataSource.newestPage(studentId);

  @override
  Future<Result<int>> getUnreadCount() =>
      Result.guard(_remoteDataSource.getUnreadCount);

  @override
  Future<Result<ChatItemEntity>> sendMessage(
    NewChatMessageEntity message, {
    UploadProgressCallback? onProgress,
    CancelHandle? cancel,
  }) => Result.guard(
    () => _remoteDataSource.sendMessage(
      NewChatMessageModel.fromEntity(message),
      onProgress: onProgress,
      cancel: cancel,
    ),
  );

  @override
  Future<Result<int>> markRead(List<String> keys) =>
      Result.guard(() => _remoteDataSource.markRead(keys));

  @override
  Future<Result<String>> downloadAttachment(
    ChatAttachmentEntity attachment, {
    CancelHandle? cancel,
  }) => Result.guard(
    () => _remoteDataSource.downloadAttachment(attachment, cancel: cancel),
  );
}
