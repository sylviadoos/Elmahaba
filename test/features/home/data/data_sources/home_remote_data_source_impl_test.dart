import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/core/network/status_code.dart';
import 'package:al_mahhaba_school/features/home/data/data_sources/home_remote_data_source_impl.dart';

import '../../home_fixtures.dart';
import 'home_remote_data_source_impl_test.mocks.dart';

/// Answers every request with one status and body, as the school's server
/// would: the whole `Dio` → `ApiService` → data source path is exercised.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({this.statusCode = StatusCode.ok, this.body, this.error});

  final int statusCode;
  final Object? body;

  /// Thrown instead of answering (a timeout, no connection…).
  final DioException Function(RequestOptions options)? error;

  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    final error = this.error;
    if (error != null) throw error(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

@GenerateNiceMocks([MockSpec<ApiService>()])
void main() {
  const childId = 9;
  final path = ApiEndpoints.childDashboard(childId);

  group('through a mocked ApiService', () {
    late MockApiService api;
    late HomeRemoteDataSourceImpl dataSource;

    setUp(() {
      api = MockApiService();
      dataSource = HomeRemoteDataSourceImpl(api);
    });

    void answer(Object? json) =>
        when(api.get(path)).thenAnswer((_) async => json);

    test(
      'asks for the child\'s dashboard, reads the school\'s answer',
      () async {
        answer({'status': 'success', 'data': dashboardJson});

        final dashboard = await dataSource.getChildDashboard(childId);

        expect(dashboard.child?.studentId, 9);
        expect(dashboard.attendance.presentDays, 3);
        expect(dashboard.messages.total, 0);
        verify(api.get(path)).called(1);
      },
    );

    test('an empty data object: nothing yet, not an error', () async {
      answer(const {'status': 'success', 'data': <String, dynamic>{}});

      final dashboard = await dataSource.getChildDashboard(childId);

      expect(dashboard.child, isNull);
      expect(dashboard.attendance.presentDays, 0);
      expect(dashboard.announcements.items, isEmpty);
      expect(dashboard.homework.items, isEmpty);
      expect(dashboard.results.items, isEmpty);
      expect(dashboard.fees, isNull);
      expect(dashboard.messages.total, 0);
    });

    test('parts sent as null: read as none', () async {
      answer(const {
        'status': 'success',
        'data': {
          'child': null,
          'attendance': null,
          'announcements': null,
          'homework': null,
          'results': null,
          'fees': null,
          'messages': null,
        },
      });

      final dashboard = await dataSource.getChildDashboard(childId);

      expect(dashboard.attendance.todayStatus, isNull);
      expect(dashboard.latestResult, isNull);
      expect(dashboard.fees, isNull);
      expect(dashboard.messages.total, 0);
    });

    test('"data" missing altogether: it throws, so the repo fails', () async {
      answer(const {'status': 'success'});

      expect(() => dataSource.getChildDashboard(childId), throwsA(anything));
    });

    test('"data" sent as a list: it throws, so the repo fails', () async {
      answer(const {'status': 'success', 'data': <Object>[]});

      expect(() => dataSource.getChildDashboard(childId), throwsA(anything));
    });

    test('the whole body null: it throws, so the repo fails', () async {
      answer(null);

      expect(() => dataSource.getChildDashboard(childId), throwsA(anything));
    });

    test('the server\'s error is passed on as it is', () async {
      when(
        api.get(path),
      ).thenThrow(const ServerException(statusCode: StatusCode.forbidden));

      expect(
        () => dataSource.getChildDashboard(childId),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('over HTTP, through ApiService', () {
    HomeRemoteDataSourceImpl sourceOn(_StubAdapter adapter) {
      final dio = Dio(BaseOptions(baseUrl: 'https://school.test/'))
        ..httpClientAdapter = adapter;
      return HomeRemoteDataSourceImpl(ApiService(dio));
    }

    Future<AppException> thrownBy(_StubAdapter adapter) async {
      try {
        await sourceOn(adapter).getChildDashboard(childId);
        fail('it answered instead of failing');
      } on AppException catch (e) {
        return e;
      }
    }

    test('200 with the dashboard: read', () async {
      final adapter = _StubAdapter(
        body: {'status': 'success', 'data': dashboardJson},
      );

      final dashboard = await sourceOn(adapter).getChildDashboard(childId);

      expect(dashboard.child?.studentId, 9);
      expect(adapter.calls, 1);
    });

    for (final status in [
      StatusCode.badRequest,
      StatusCode.forbidden,
      StatusCode.notFound,
      StatusCode.internalServerError,
    ]) {
      test('$status: a ServerException with the status and message', () async {
        final exception = await thrownBy(
          _StubAdapter(
            statusCode: status,
            body: const {'message': 'Something went wrong', 'code': 'oops'},
          ),
        );

        expect(exception, isA<ServerException>());
        expect(exception.statusCode, status);
        expect(exception.message, 'Something went wrong');
        expect((exception as ServerException).code, 'oops');
      });
    }

    test('401: the session ended, so the parent is asked to log in', () async {
      final exception = await thrownBy(
        _StubAdapter(
          statusCode: StatusCode.expiredToken,
          body: const {'code': 'unauthenticated'},
        ),
      );

      expect(exception, isA<UnauthorizedException>());
      expect((exception as UnauthorizedException).isAccountWithdrawn, isFalse);
    });

    test(
      '403 account_withdrawn: the account is closed, not the session',
      () async {
        final exception = await thrownBy(
          _StubAdapter(
            statusCode: StatusCode.forbidden,
            body: const {'code': 'account_withdrawn', 'message': 'Withdrawn'},
          ),
        );

        expect(exception, isA<UnauthorizedException>());
        expect((exception as UnauthorizedException).isAccountWithdrawn, isTrue);
      },
    );

    test('500 with an HTML body: still a ServerException', () async {
      final exception = await thrownBy(
        _StubAdapter(
          statusCode: StatusCode.internalServerError,
          body: '<html>Bad Gateway</html>',
        ),
      );

      expect(exception, isA<ServerException>());
      expect(exception.statusCode, StatusCode.internalServerError);
      // Nothing to show from the body: the UI shows its own text.
      expect(exception.message, isNull);
    });

    test('200 with a body that isn\'t the dashboard: it throws a plain '
        'error, which only the repo turns into a failure', () async {
      final source = sourceOn(_StubAdapter(body: 'not the dashboard'));

      // Not an AppException: `Result.guard` in `HomeRepoImpl` is what keeps
      // this from reaching the bloc (see home_repo_impl_test.dart).
      await expectLater(
        source.getChildDashboard(childId),
        throwsA(isA<TypeError>()),
      );
    });

    test('no connection: NetworkException', () async {
      final exception = await thrownBy(
        _StubAdapter(
          error: (options) => DioException.connectionError(
            requestOptions: options,
            reason: 'Failed host lookup',
          ),
        ),
      );

      expect(exception, isA<NetworkException>());
    });

    test('the school didn\'t answer in time: NetworkException', () async {
      final exception = await thrownBy(
        _StubAdapter(
          error: (options) => DioException.receiveTimeout(
            timeout: const Duration(seconds: 30),
            requestOptions: options,
          ),
        ),
      );

      expect(exception, isA<NetworkException>());
    });

    test('connecting timed out: NetworkException', () async {
      final exception = await thrownBy(
        _StubAdapter(
          error: (options) => DioException.connectionTimeout(
            timeout: const Duration(seconds: 30),
            requestOptions: options,
          ),
        ),
      );

      expect(exception, isA<NetworkException>());
    });

    test('cancelled (the parent left Home): CancelledException', () async {
      final exception = await thrownBy(
        _StubAdapter(
          error: (options) => DioException.requestCancelled(
            requestOptions: options,
            reason: null,
          ),
        ),
      );

      expect(exception, isA<CancelledException>());
    });
  });
}
