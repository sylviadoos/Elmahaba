import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_remote_data_source_impl.dart';

import 'chat_remote_data_source_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ApiService>()])
void main() {
  late MockApiService api;
  late ChatRemoteDataSourceImpl dataSource;

  setUp(() {
    api = MockApiService();
    dataSource = ChatRemoteDataSourceImpl(api, MockApiService());
  });

  test(
    'unread: asked for the child (the school requires it), the total',
    () async {
      when(
        api.get(
          ApiEndpoints.chatUnreadCount,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => {
          'status': 'success',
          'data': {'messages': 1, 'group_messages': 0, 'events': 1, 'total': 2},
        },
      );

      expect(await dataSource.getUnreadCount(studentId: 151), 2);
      verify(
        api.get(
          ApiEndpoints.chatUnreadCount,
          queryParameters: {'student_id': 151},
        ),
      ).called(1);
    },
  );
}
