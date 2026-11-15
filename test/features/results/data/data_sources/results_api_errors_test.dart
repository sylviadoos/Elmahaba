import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/data/data_sources/results_remote_data_source_impl.dart';
import 'package:al_mahhaba_school/features/results/data/repos/results_repo_impl.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_kind.dart';

import '../../../../helpers/result_matchers.dart';
import '../../results_fixtures.dart';

/// Answers every request with what the test set, so the status codes and
/// the failures go through the real `Dio` and the real `ApiService` — the
/// same path a phone takes.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._answer);

  final FutureOr<ResponseBody> Function(RequestOptions options) _answer;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return _answer(options);
  }

  @override
  void close({bool force = false}) {}
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
  ResultsRemoteDataSourceImpl sourceAnswering(
    Object? body, {
    int statusCode = 200,
  }) => ResultsRemoteDataSourceImpl(
    apiWith(
      (_) => ResponseBody.fromString(
        jsonEncode(body),
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    ),
  );

  /// A data source whose request fails the way [type] says.
  ResultsRemoteDataSourceImpl sourceFailing(DioExceptionType type) =>
      ResultsRemoteDataSourceImpl(
        apiWith(
          (options) => throw DioException(requestOptions: options, type: type),
        ),
      );

  Future<Object?> errorOf(ResultsRemoteDataSourceImpl source) async {
    try {
      await source.getResults(146, kind: ResultKind.monthly);
      return null;
    } catch (error) {
      return error;
    }
  }

  group('the school answers, but with an error status', () {
    test('400: a server error the page can show, status kept', () async {
      final error = await errorOf(
        sourceAnswering({
          'status': 'error',
          'message': 'Bad request',
        }, statusCode: 400),
      );

      expect(error, isA<ServerException>());
      expect((error! as ServerException).statusCode, 400);
      expect((error as ServerException).message, 'Bad request');
    });

    test('401: the session ended, so Results offers "Log in"', () async {
      final error = await errorOf(
        sourceAnswering({'message': 'Unauthenticated.'}, statusCode: 401),
      );

      expect(error, isA<UnauthorizedException>());
      expect((error! as UnauthorizedException).isAccountWithdrawn, isFalse);
    });

    test('401 account_withdrawn: signed out, not just the session', () async {
      final error = await errorOf(
        sourceAnswering({
          'code': 'account_withdrawn',
          'message': 'The child left the school.',
        }, statusCode: 401),
      );

      expect(error, isA<UnauthorizedException>());
      expect((error! as UnauthorizedException).isAccountWithdrawn, isTrue);
    });

    test('403: a server error, not a sign out', () async {
      final error = await errorOf(
        sourceAnswering({'message': 'Forbidden'}, statusCode: 403),
      );

      expect(error, isA<ServerException>());
      expect((error! as ServerException).statusCode, 403);
    });

    test('404: a server error with its status', () async {
      final error = await errorOf(
        sourceAnswering({'message': 'Not found'}, statusCode: 404),
      );

      expect(error, isA<ServerException>());
      expect((error! as ServerException).statusCode, 404);
    });

    test('500: a server error with its status', () async {
      final error = await errorOf(
        sourceAnswering({'message': 'Server Error'}, statusCode: 500),
      );

      expect(error, isA<ServerException>());
      expect((error! as ServerException).statusCode, 500);
    });

    test('500 with an HTML body: still a server error, no crash', () async {
      final source = ResultsRemoteDataSourceImpl(
        apiWith(
          (_) => ResponseBody.fromString(
            '<html><body>502 Bad Gateway</body></html>',
            502,
            headers: {
              Headers.contentTypeHeader: ['text/html'],
            },
          ),
        ),
      );

      final error = await errorOf(source);

      expect(error, isA<ServerException>());
      expect((error! as ServerException).statusCode, 502);
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

    test('the request was cancelled: said so, not an unknown error', () async {
      expect(
        await errorOf(sourceFailing(DioExceptionType.cancel)),
        isA<CancelledException>(),
      );
    });
  });

  group('the school answers 200, but not with results', () {
    test('"data": null — none, rather than a crash', () async {
      expect(
        await sourceAnswering({
          'status': 'success',
          'data': null,
        }).getResults(146, kind: ResultKind.monthly),
        isEmpty,
      );
    });

    test('no "data" at all — none', () async {
      expect(
        await sourceAnswering({
          'status': 'success',
        }).getResults(146, kind: ResultKind.monthly),
        isEmpty,
      );
    });

    test('"data": {} instead of a list — none', () async {
      expect(
        await sourceAnswering({
          'status': 'success',
          'data': <String, dynamic>{},
        }).getResults(146, kind: ResultKind.monthly),
        isEmpty,
      );
    });

    test('a list with nulls and odd entries: only the real ones', () async {
      final results = await sourceAnswering({
        'status': 'success',
        'data': [null, 'nonsense', 42, octoberJson],
      }).getResults(146, kind: ResultKind.monthly);

      expect(results.map((result) => result.id), [820]);
    });

    test('one result with "data": [] costs nothing to the others: both come '
        'back, that one with nothing on it', () async {
      final repo = ResultsRepoImpl(
        sourceAnswering({
          'status': 'success',
          'data': [
            octoberJson,
            {
              'result_id': 999,
              'result_type': 'monthly',
              'published_at': '2026-12-20T10:00:00+00:00',
              'data': <dynamic>[],
            },
          ],
        }),
      );

      final result = await repo.getResults(146);

      // Both kinds are asked for, so each result comes back twice here;
      // what matters is that October survived the empty one beside it.
      expect(result, isA<Success<List<ResultDetailsEntity>>>());
      final results = (result as Success<List<ResultDetailsEntity>>).data;
      expect(results.map((each) => each.id), contains(820));
      expect(results.map((each) => each.id), contains(999));
      final empty = results.firstWhere((each) => each.id == 999);
      expect(empty.subjectsIncluded, isEmpty);
      expect(empty.finalResult, isNull);
      final october = results.firstWhere((each) => each.id == 820);
      expect(october.subjectsIncluded.single.name, 'Arabic');
      expect(october.finalResult, 245);
    });

    test('an empty body: a repo failure, not a thrown error', () async {
      final repo = ResultsRepoImpl(sourceAnswering(''));

      expect(await repo.getResults(146), isFailure<UnknownException>());
    });

    test('a list where the object should be: a repo failure', () async {
      final repo = ResultsRepoImpl(sourceAnswering([octoberJson]));

      expect(await repo.getResults(146), isFailure<UnknownException>());
    });
  });

  test('both kinds are asked for, each with its own request', () async {
    final source = sourceAnswering({'status': 'success', 'data': []});
    final repo = ResultsRepoImpl(source);

    expect(await repo.getResults(146), isSuccess<List<Object?>>(isEmpty));
    expect(adapter.calls, 2);
  });
}
