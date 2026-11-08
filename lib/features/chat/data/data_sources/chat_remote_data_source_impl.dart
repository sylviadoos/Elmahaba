import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:al_mahhaba_school/features/chat/data/models/chat_item_model.dart';
import 'package:al_mahhaba_school/features/chat/data/models/chat_page_model.dart';
import 'package:al_mahhaba_school/features/chat/data/models/new_chat_message_model.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';

@LazySingleton(as: ChatRemoteDataSource)
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl(
    @Named(ApiNames.school) this._api,
    @Named(ApiNames.signedFiles) this._signedFiles,
  );

  final ApiService _api;

  /// For the signed links files are fetched by: without the token.
  final ApiService _signedFiles;

  static const int _limit = 30;

  @override
  Future<ChatPageModel> getChat({
    int? studentId,
    String? before,
    CancelHandle? cancel,
  }) async {
    final json =
        await _api.get(
              ApiEndpoints.chat,
              queryParameters: {
                'limit': _limit,
                'student_id': ?studentId,
                'before': ?before,
              },
              cancelToken: cancel?.token,
            )
            as Map<String, dynamic>;
    return ChatPageModel.fromJson(json);
  }

  @override
  Future<int> getUnreadCount() async {
    // { "status": "success", "data": { "messages": 1, "group_messages": 0,
    //   "events": 1, "total": 2 } }
    final json =
        await _api.get(ApiEndpoints.chatUnreadCount) as Map<String, dynamic>;
    final data = json[ApiKeys.data] as Map<String, dynamic>? ?? const {};
    return data['total'] as int? ?? 0;
  }

  @override
  Future<ChatItemModel> sendMessage(
    NewChatMessageModel message, {
    UploadProgressCallback? onProgress,
    CancelHandle? cancel,
  }) async {
    // { "status": "success", "code": "message_sent", "data": { …item… } }
    final json =
        await _api.upload(
              ApiEndpoints.chatMessages,
              formData: await message.toFormData(),
              onSendProgress: onProgress,
              cancelToken: cancel?.token,
            )
            as Map<String, dynamic>;
    return ChatItemModel.fromJson(json[ApiKeys.data] as Map<String, dynamic>);
  }

  @override
  Future<int> markRead(List<String> keys) async {
    // { "status": "success", "data": { "marked": 2, "not_found": [],
    //   "unread": 0 } }
    final json =
        await _api.post(ApiEndpoints.chatRead, data: {'items': keys})
            as Map<String, dynamic>;
    final data = json[ApiKeys.data] as Map<String, dynamic>? ?? const {};
    return data['unread'] as int? ?? 0;
  }

  @override
  Future<String> downloadAttachment(
    ChatAttachmentEntity attachment, {
    CancelHandle? cancel,
  }) async {
    final folder = await getTemporaryDirectory();
    // The server's name, minus anything that would leave the folder.
    final name = attachment.fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final file = File('${folder.path}/chat_attachments/${attachment.id}_$name');
    if (!await file.exists()) {
      // { "status": "success", "data": { "id": 77, "url": "…/signed/77?…",
      //   "expires_in_minutes": 10 } }
      final json =
          await _api.get(
                ApiEndpoints.chatAttachment(attachment.id),
                cancelToken: cancel?.token,
              )
              as Map<String, dynamic>;
      final data = json[ApiKeys.data] as Map<String, dynamic>;
      await file.parent.create(recursive: true);
      await _signedFiles.download(
        data['url'] as String,
        file.path,
        cancelToken: cancel?.token,
      );
    }
    return file.path;
  }
}
