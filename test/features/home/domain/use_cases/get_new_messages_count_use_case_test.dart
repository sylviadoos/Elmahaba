import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/message_counts_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/extensions/dashboard_chat_counts.dart';
import 'package:al_mahhaba_school/features/home/domain/use_cases/get_new_messages_count_use_case.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/result_matchers.dart';
import '../../home_fixtures.dart';
import '../../home_mocks.mocks.dart';

void main() {
  late MockHomeRepo repo;
  late GetNewMessagesCountUseCase getNewMessagesCount;

  setUpAll(() => provideResultDummy<ChildDashboardEntity>());

  setUp(() {
    repo = MockHomeRepo();
    getNewMessagesCount = GetNewMessagesCountUseCase(repo);
  });

  test('what the School chat card says: its messages and notices', () async {
    // The school says no notices, though an announcement and homework are
    // unread: the card counts them, so the badge does too.
    final dashboard = dashboardWith(
      messages: const MessageCountsEntity(messages: 1, notices: 0, total: 1),
    );
    when(
      repo.getChildDashboard(9),
    ).thenAnswer((_) async => Success(data: dashboard));

    expect(await getNewMessagesCount(9), isSuccess<int>(3));
    expect(dashboard.unreadChat.total, 3);
  });

  test('the dashboard didn\'t load: why', () async {
    when(
      repo.getChildDashboard(9),
    ).thenAnswer((_) async => const Failure(exception: NetworkException()));

    expect(await getNewMessagesCount(9), isFailure<NetworkException>());
  });
}
