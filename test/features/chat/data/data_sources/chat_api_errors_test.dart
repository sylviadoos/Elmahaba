import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/core/pdf/pdf_previewer.dart';
import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_local_data_source_impl.dart';
import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_remote_data_source_impl.dart';
import 'package:al_mahhaba_school/features/chat/data/models/new_chat_message_model.dart';
import 'package:al_mahhaba_school/features/chat/data/repos/chat_repo_impl.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_sender.dart';

import '../../../../helpers/result_matchers.dart';

/// Answers every request with what the test set, so the status codes and
/// the failures go through the real `Dio` and the real `ApiService` — the
/// same path a phone takes.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._answer);

  final FutureOr<ResponseBody> Function(RequestOptions options) _answer;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _answer(options);
  }

  @override
  void close({bool force = false}) {}
}

/// No PDF is previewed in these tests.
class _NoPdfPreviewer implements PdfPreviewer {
  @override
  Future<String> firstPage(String pdfPath) => throw UnimplementedError();
}

void main() {
  late _FakeAdapter adapter;

  /// The real `ApiService` over a `Dio` whose server is [answer].
  ApiService apiWith(FutureOr<ResponseBody> Function(RequestOptions) answer) {
    adapter = _FakeAdapter(answer);
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://school.test/',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    )..httpClientAdapter = adapter;
    return ApiService(dio);
  }

  /// A data source whose server answers with [body] at [statusCode].
  ChatRemoteDataSourceImpl sourceAnswering(Object? body, {int status = 200}) {
    final api = apiWith(
      (_) => ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
    return ChatRemoteDataSourceImpl(api, api);
  }

  /// A data source whose request fails the way [type] says.
  ChatRemoteDataSourceImpl sourceFailing(DioExceptionType type) {
    final api = apiWith(
      (options) => throw DioException(requestOptions: options, type: type),
    );
    return ChatRemoteDataSourceImpl(api, api);
  }

  /// What `getChat` threw, or null when it didn't.
  Future<Object?> errorOf(ChatRemoteDataSourceImpl source) async {
    try {
      await source.getChat(studentId: 1208);
      return null;
    } catch (error) {
      return error;
    }
  }

  /// A chat body with [items] and the meta the school sends.
  Map<String, dynamic> chatBody(
    List<Map<String, dynamic>> items, {
    Map<String, dynamic>? meta,
  }) => {
    'status': 'success',
    'data': items,
    'meta':
        meta ??
        {
          'has_more': false,
          'next_before': null,
          'unread': 0,
          'chat_open': true,
          'can_send': true,
        },
  };

  Map<String, dynamic> itemBody({
    String key = 'message:41',
    String sender = 'school',
  }) => {
    'key': key,
    'kind': 'message',
    'sender': sender,
    'created_at': '2026-11-04T08:15:00+00:00',
    'scope': 'private',
    'children': [
      {'student_id': 1208, 'name': 'Omar Ahmed', 'name_ar': 'عمر أحمد'},
    ],
    'text': 'Please bring the signed trip form tomorrow.',
    'attachments': const <Object?>[],
    'is_read': false,
    'edited': false,
    'deleted': false,
    'can_reply': true,
  };

  group('the school answers', () {
    test('a chat: items, cursor and what the parent may do', () async {
      final page = await sourceAnswering(
        chatBody(
          [itemBody()],
          meta: {
            'has_more': true,
            'next_before': 'cursor-1',
            'unread': 3,
            'chat_open': true,
            'can_send': true,
          },
        ),
      ).getChat(studentId: 1208);

      expect(page.items.single.key, 'message:41');
      expect(page.items.single.sender, ChatSender.school);
      expect(page.hasMore, isTrue);
      expect(page.nextBefore, 'cursor-1');
      expect(page.unread, 3);
      expect(page.canSend, isTrue);
      expect(adapter.requests.single.queryParameters, {
        'limit': 30,
        'student_id': 1208,
      });
    });

    test('nothing yet: an empty chat, not an error', () async {
      final page = await sourceAnswering(chatBody([])).getChat();

      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
      expect(page.nextBefore, isNull);
    });

    test('data and meta null: an empty chat, no crash', () async {
      final page = await sourceAnswering({
        'status': 'success',
        'data': null,
        'meta': null,
      }).getChat();

      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
      expect(page.unread, 0);
      // Nothing may be sent unless the school says it may.
      expect(page.canSend, isFalse);
      // Readable unless the school says it's closed.
      expect(page.isOpen, isTrue);
    });

    test('an item missing every field: defaults, no crash', () async {
      final page = await sourceAnswering(
        chatBody([<String, dynamic>{}]),
      ).getChat();

      final item = page.items.single;
      expect(item.key, '');
      expect(item.text, '');
      expect(item.sender, ChatSender.school);
      expect(item.sentAt, isNull);
      // Unknown items aren't shown as new.
      expect(item.isRead, isTrue);
      expect(item.canReply, isFalse);
      expect(item.attachments, isEmpty);
    });

    test('items of the wrong shape in the list: skipped', () async {
      final page = await sourceAnswering({
        'status': 'success',
        'data': ['a string', 42, itemBody()],
        'meta': const <String, dynamic>{},
      }).getChat();

      expect(page.items.single.key, 'message:41');
    });

    test('"has_more" without a cursor: no more to ask for', () async {
      final page = await sourceAnswering(
        chatBody([itemBody()], meta: {'has_more': true, 'next_before': null}),
      ).getChat();

      expect(page.hasMore, isFalse);
    });

    test('a list where an object belongs: an unknown error', () async {
      final error = await errorOf(sourceAnswering([itemBody()]));

      expect(error, isA<TypeError>());
    });

    test('read: what is left unread; 0 when it doesn\'t say', () async {
      expect(
        await sourceAnswering({
          'status': 'success',
          'data': {'marked': 2, 'not_found': <Object?>[], 'unread': 4},
        }).markRead(['message:41'], studentId: 1208),
        4,
      );
      expect(
        await sourceAnswering({
          'status': 'success',
          'data': <String, dynamic>{},
        }).markRead(['message:41']),
        0,
      );
    });

    test('a message sent back without its item: the school is at fault, '
        'not "unknown"', () async {
      Object? error;
      try {
        await sourceAnswering({
          'status': 'success',
          'code': 'message_sent',
        }).sendMessage(_message);
      } catch (e) {
        error = e;
      }

      // The parent is told the school had trouble, not that something
      // unknown happened; the whole answer is kept to report.
      expect(error, isA<ServerException>());
      expect((error! as ServerException).body['code'], 'message_sent');
    });
  });

  group('the school answers with an error status', () {
    test('400: a server error the page can show, status kept', () async {
      final error = await errorOf(
        sourceAnswering({'message': 'Bad request'}, status: 400),
      );

      expect(error, isA<ServerException>());
      expect((error! as ServerException).statusCode, 400);
      expect((error as ServerException).message, 'Bad request');
    });

    test('401: the session ended, so the chat offers "Log in"', () async {
      final error = await errorOf(
        sourceAnswering({'message': 'Unauthenticated.'}, status: 401),
      );

      expect(error, isA<UnauthorizedException>());
      expect((error! as UnauthorizedException).isAccountWithdrawn, isFalse);
    });

    test('401 account_withdrawn: signed out, not just the session', () async {
      final error = await errorOf(
        sourceAnswering({
          'code': 'account_withdrawn',
          'message': 'The child left the school.',
        }, status: 401),
      );

      expect(error, isA<UnauthorizedException>());
      expect((error! as UnauthorizedException).isAccountWithdrawn, isTrue);
    });

    test('403: a server error, not a sign out', () async {
      final error = await errorOf(
        sourceAnswering({'message': 'Forbidden'}, status: 403),
      );

      expect(error, isA<ServerException>());
      expect((error! as ServerException).statusCode, 403);
    });

    test('404: a server error with its status', () async {
      final error = await errorOf(
        sourceAnswering({'message': 'Not found'}, status: 404),
      );

      expect(error, isA<ServerException>());
      expect((error! as ServerException).statusCode, 404);
    });

    test('500: a server error with its status', () async {
      final error = await errorOf(
        sourceAnswering({'message': 'Server Error'}, status: 500),
      );

      expect(error, isA<ServerException>());
      expect((error! as ServerException).statusCode, 500);
    });

    test('502 with an HTML body: still a server error, no crash', () async {
      final api = apiWith(
        (_) => ResponseBody.fromString(
          '<html><body>502 Bad Gateway</body></html>',
          502,
          headers: {
            Headers.contentTypeHeader: ['text/html'],
          },
        ),
      );
      final error = await errorOf(ChatRemoteDataSourceImpl(api, api));

      expect(error, isA<ServerException>());
      expect((error! as ServerException).statusCode, 502);
    });

    test('422 on a message: the field errors are kept', () async {
      Object? error;
      try {
        await sourceAnswering({
          'message': 'The given data was invalid.',
          'code': 'file_rejected',
          'file_name': 'party.mp4',
          'errors': {
            'attachments.0': ['The file type is not allowed.'],
          },
        }, status: 422).sendMessage(_message);
      } catch (e) {
        error = e;
      }

      expect(error, isA<ServerException>());
      final server = error! as ServerException;
      expect(server.code, 'file_rejected');
      expect(server.body['file_name'], 'party.mp4');
      expect(
        server.fieldErrors['attachments.0'],
        'The file type is not allowed.',
      );
    });
  });

  group('the school can\'t be reached', () {
    test('no internet: a network error', () async {
      expect(
        await errorOf(sourceFailing(DioExceptionType.connectionError)),
        isA<NetworkException>(),
      );
    });

    test('it timed out while connecting: a network error', () async {
      expect(
        await errorOf(sourceFailing(DioExceptionType.connectionTimeout)),
        isA<NetworkException>(),
      );
    });

    test('it timed out while answering: a network error', () async {
      expect(
        await errorOf(sourceFailing(DioExceptionType.receiveTimeout)),
        isA<NetworkException>(),
      );
    });

    test('the parent left the page: cancelled, not an error to show', () async {
      expect(
        await errorOf(sourceFailing(DioExceptionType.cancel)),
        isA<CancelledException>(),
      );
    });
  });

  group('through the repository', () {
    ChatRepoImpl repoOver(
      ChatRemoteDataSourceImpl source,
      ChatLocalDataSourceImpl local,
    ) => ChatRepoImpl(source, local, _NoPdfPreviewer());

    test('every failure comes back as a Result, never thrown', () async {
      final local = ChatLocalDataSourceImpl();
      final result = await repoOver(
        sourceAnswering({'message': 'Server Error'}, status: 500),
        local,
      ).getChat(studentId: 1208);

      expect(result, isFailure<ServerException>());
      // Nothing was kept from a failed load.
      expect(local.newestPage(1208), isNull);
    });

    test('a body of the wrong shape: an unknown error, no crash', () async {
      final result = await repoOver(
        sourceAnswering([itemBody()]),
        ChatLocalDataSourceImpl(),
      ).getChat();

      expect(result, isFailure<UnknownException>());
    });

    test('a full page is kept; the latest few are not', () async {
      final local = ChatLocalDataSourceImpl();
      final repo = repoOver(sourceAnswering(chatBody([itemBody()])), local);

      await repo.getChat(studentId: 1208);
      expect(local.newestPage(1208)?.items.single.key, 'message:41');

      // A refresh (limit) and older items (before) leave the kept page.
      final kept = local.newestPage(1208);
      await repo.getChat(studentId: 1208, limit: 5);
      await repo.getChat(studentId: 1208, before: 'cursor-1');
      expect(identical(local.newestPage(1208), kept), isTrue);
    });

    test('each child\'s chat is kept apart', () async {
      final local = ChatLocalDataSourceImpl();
      final repo = repoOver(sourceAnswering(chatBody([itemBody()])), local);

      await repo.getChat(studentId: 1208);

      expect(local.newestPage(1208), isNotNull);
      expect(local.newestPage(1209), isNull);
      expect(local.newestPage(null), isNull);
    });
  });
}

/// The smallest message the data source can send.
const _message = NewChatMessageModel(text: 'Thank you.', clientUuid: 'uuid-1');
