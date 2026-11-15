import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/announcements/data/data_sources/announcements_remote_data_source_impl.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';

import '../../announcements_fixtures.dart';
import 'announcements_remote_data_source_impl_test.mocks.dart';

/// What an announcement says, whether it's the entity or the model parsed:
/// Equatable tells the two types apart.
List<Object?> _fields(AnnouncementEntity announcement) => [
  ...announcement.props.where((prop) => prop is! List && prop is! Equatable),
  ...?announcement.audience?.props,
  for (final file in announcement.attachments) ...file.props,
];

@GenerateNiceMocks([MockSpec<ApiService>()])
void main() {
  late MockApiService api;
  late AnnouncementsRemoteDataSourceImpl dataSource;

  setUp(() {
    api = MockApiService();
    dataSource = AnnouncementsRemoteDataSourceImpl(api);
  });

  Map<String, dynamic> announcement({
    required int id,
    required String title,
    required String? expiresAt,
    required bool expired,
    required String chatKey,
    required bool isRead,
  }) => {
    'id': id,
    'title': title,
    'body': 'Parents meeting on Sunday at 10 AM.',
    'published_at': '2026-11-07T08:00:00+00:00',
    'expires_at': expiresAt,
    'expired': expired,
    'edited': false,
    'last_updated': null,
    'attachments': [
      {
        'id': 77,
        'file_name': 'agenda.pdf',
        'mime': 'application/pdf',
        'size': 84211,
        'status': 'available',
      },
    ],
    'scope': 'general',
    'audience': {
      'type': 'all',
      'name': 'All parents',
      'name_ar': 'كل أولياء الأمور',
    },
    'chat_key': chatKey,
    'is_read': isRead,
  };

  /// The API's example response.
  final response = {
    'status': 'success',
    'data': [
      announcement(
        id: 9,
        title: 'Parents meeting',
        expiresAt: null,
        expired: false,
        chatKey: 'event:40',
        isRead: false,
      ),
      announcement(
        id: 7,
        title: 'Sports day',
        expiresAt: '2026-11-01T10:00:00+00:00',
        expired: true,
        chatKey: 'event:31',
        isRead: true,
      ),
    ],
    'meta': {
      'page': 1,
      'per_page': 10,
      'total': 2,
      'last_page': 1,
      'unread': 1,
    },
  };

  test('asks for the first page of ten, reads the announcements', () async {
    when(
      api.get(
        ApiEndpoints.childAnnouncements(omar.studentId),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).thenAnswer((_) async => response);

    final page = await dataSource.getAnnouncements(omar.studentId);

    expect(page.items.map(_fields), [_fields(meeting), _fields(sportsDay)]);
    expect(page.page, 1);
    expect(page.hasMore, isFalse);
    expect(page.total, 2);
    expect(page.unread, 1);
    verify(
      api.get(
        ApiEndpoints.childAnnouncements(omar.studentId),
        queryParameters: {'page': 1, 'per_page': 10},
        cancelToken: anyNamed('cancelToken'),
      ),
    ).called(1);
  });

  test('a later page, and a way to stop it', () async {
    final cancel = CancelHandle();
    when(
      api.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).thenAnswer((_) async => response);

    await dataSource.getAnnouncements(omar.studentId, page: 2, cancel: cancel);

    verify(
      api.get(
        ApiEndpoints.childAnnouncements(omar.studentId),
        queryParameters: {'page': 2, 'per_page': 10},
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
      const ServerException(
        statusCode: 403,
        code: 'read_only_child',
        message: 'This action is not available for this child.',
      ),
    );

    expect(
      () => dataSource.getAnnouncements(omar.studentId),
      throwsA(
        isA<ServerException>().having((e) => e.code, 'code', 'read_only_child'),
      ),
    );
  });
}
