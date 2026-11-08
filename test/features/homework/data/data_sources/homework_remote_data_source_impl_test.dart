import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/homework/data/data_sources/homework_remote_data_source_impl.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_filter.dart';

import '../../homework_fixtures.dart';
import 'homework_remote_data_source_impl_test.mocks.dart';

/// What a homework says, whether it's the entity or the model parsed:
/// Equatable tells the two types apart.
List<Object?> _fields(HomeworkEntity homework) => [
  ...homework.props.where((prop) => prop is! List),
  for (final file in homework.attachments) ...file.props,
];

@GenerateNiceMocks([MockSpec<ApiService>()])
void main() {
  late MockApiService api;
  late HomeworkRemoteDataSourceImpl dataSource;

  setUp(() {
    api = MockApiService();
    dataSource = HomeworkRemoteDataSourceImpl(api);
  });

  /// The API's example response.
  final response = {
    'status': 'success',
    'data': [
      {
        'id': 12,
        'title': 'Ex 1',
        'subject': 'Math',
        'subject_id': 3,
        'description': 'Pages 1-3',
        'issue_date': '2026-11-08',
        'due_date': '2026-11-11',
        'due_status': 'upcoming',
        'edited': false,
        'last_updated': null,
        'attachments': [
          {
            'id': 88,
            'file_name': 'ex1.pdf',
            'mime': 'application/pdf',
            'size': 52344,
            'status': 'available',
          },
        ],
        'chat_key': 'event:41',
        'is_read': false,
      },
      {
        'id': 11,
        'title': 'Read chapter 2',
        'subject': 'Arabic',
        'subject_id': 5,
        'description': 'At home',
        'issue_date': '2026-11-06',
        'due_date': null,
        'due_status': 'no_due_date',
        'edited': true,
        'last_updated': '2026-11-07T09:15:00+02:00',
        'attachments': <Object>[],
        'chat_key': 'event:38',
        'is_read': true,
      },
    ],
    'meta': {
      'page': 1,
      'per_page': 20,
      'total': 2,
      'last_page': 1,
      'unread': 1,
      'subjects': [
        {'id': 3, 'name': 'Math'},
        {'id': 5, 'name': 'Arabic'},
      ],
    },
  };

  group('getHomework', () {
    test('asks for a page of all of it, reads the homework', () async {
      when(
        api.get(
          ApiEndpoints.childHomework(omar.studentId),
          queryParameters: anyNamed('queryParameters'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => response);

      final page = await dataSource.getHomework(omar.studentId);

      expect(page.items.map(_fields), [_fields(exercise), _fields(reading)]);
      expect(page.page, 1);
      expect(page.lastPage, 1);
      expect(page.hasMore, isFalse);
      expect(page.total, 2);
      expect(page.unread, 1);
      expect(page.subjects.map((subject) => subject.props), [
        math.props,
        arabic.props,
      ]);
      verify(
        api.get(
          ApiEndpoints.childHomework(omar.studentId),
          queryParameters: {'status': 'all', 'page': 1, 'per_page': 20},
          cancelToken: anyNamed('cancelToken'),
        ),
      ).called(1);
    });

    test('a filter, a subject, a later page, and a way to stop it', () async {
      final cancel = CancelHandle();
      when(
        api.get(
          any,
          queryParameters: anyNamed('queryParameters'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => response);

      await dataSource.getHomework(
        omar.studentId,
        filter: HomeworkFilter.dueSoon,
        subjectId: 3,
        page: 2,
        cancel: cancel,
      );

      verify(
        api.get(
          ApiEndpoints.childHomework(omar.studentId),
          queryParameters: {
            'status': 'due_soon',
            'subject_id': 3,
            'page': 2,
            'per_page': 20,
          },
          cancelToken: cancel.token,
        ),
      ).called(1);
    });

    test('a read-only child: the server\'s error', () async {
      when(
        api.get(
          any,
          queryParameters: anyNamed('queryParameters'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenThrow(
        const ServerException(statusCode: 403, code: 'read_only_child'),
      );

      expect(
        () => dataSource.getHomework(omar.studentId),
        throwsA(
          isA<ServerException>().having(
            (e) => e.code,
            'code',
            'read_only_child',
          ),
        ),
      );
    });
  });
}
