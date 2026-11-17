import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/message_counts_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/extensions/dashboard_chat_counts.dart';
import 'package:al_mahhaba_school/features/home/domain/use_cases/get_child_dashboard_use_case.dart';
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

  group('shared with Home', sharedWithHome);
}

/// The badge on Chat and Home both read the same dashboard: this is what
/// that costs when the two ask at once, as they do when the children
/// arrive, on resume, and on every notification.
void sharedWithHome() {
  late MockHomeRepo repo;
  late GetNewMessagesCountUseCase getNewMessagesCount;
  late GetChildDashboardUseCase getChildDashboard;

  setUpAll(() => provideResultDummy<ChildDashboardEntity>());

  setUp(() {
    repo = MockHomeRepo();
    getNewMessagesCount = GetNewMessagesCountUseCase(repo);
    getChildDashboard = GetChildDashboardUseCase(repo);
  });

  test(
    'the badge and Home ask for the same child\'s dashboard: the school '
    'is asked twice for one answer, with nothing shared between them',
    () async {
      final dashboard = dashboardWith();
      var calls = 0;
      when(repo.getChildDashboard(9)).thenAnswer((_) async {
        calls++;
        return Success(data: dashboard);
      });

      // `BadgeRefresher` and `HomePage` both react to the children arriving.
      await Future.wait([getNewMessagesCount(9), getChildDashboard(9)]);

      // Recorded as it behaves today: no cache and no in-flight sharing, so
      // the same endpoint is hit twice at the same moment.
      expect(calls, 2);
    },
  );
}
