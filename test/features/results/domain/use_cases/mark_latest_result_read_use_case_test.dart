import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/dashboard_attendance_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_items_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_result_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/message_counts_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/use_cases/mark_latest_result_read_use_case.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/result_matchers.dart';
import '../../results_mocks.mocks.dart';

LatestResultEntity _result({bool isRead = false, String? chatKey}) =>
    LatestResultEntity(
      id: 820,
      title: 'نتيجة شهر أكتوبر',
      academicYear: '2026-2027',
      resultType: 'value and color',
      isRead: isRead,
      chatKey: chatKey,
    );

void main() {
  late MockHomeRepo homeRepo;
  late MockChatRepo chatRepo;
  late MarkLatestResultReadUseCase markLatestRead;

  setUpAll(() {
    provideResultDummy<ChildDashboardEntity>();
    provideResultDummy<int>();
  });

  setUp(() {
    homeRepo = MockHomeRepo();
    chatRepo = MockChatRepo();
    when(
      chatRepo.markRead(any, studentId: anyNamed('studentId')),
    ).thenAnswer((_) async => const Success(data: 0));
    markLatestRead = MarkLatestResultReadUseCase(homeRepo, chatRepo);
  });

  void dashboardWith({
    LatestResultEntity? latest,
    List<LatestResultEntity> listed = const [],
  }) => when(homeRepo.getChildDashboard(any)).thenAnswer(
    (_) async => Success(
      data: ChildDashboardEntity(
        attendance: const DashboardAttendanceEntity(),
        messages: const MessageCountsEntity(messages: 0, notices: 0, total: 0),
        latestResult: latest,
        results: LatestItemsEntity(items: listed),
      ),
    ),
  );

  test('new on Home: its chat item is read', () async {
    dashboardWith(
      latest: _result(),
      listed: [_result(chatKey: 'event:34')],
    );

    expect(await markLatestRead(146), isSuccess<void>(anything));
    verify(homeRepo.getChildDashboard(146));
    verify(chatRepo.markRead(['event:34'], studentId: 146)).called(1);
  });

  test('read already: nothing is sent', () async {
    dashboardWith(
      listed: [_result(isRead: true, chatKey: 'event:34')],
      latest: _result(isRead: true, chatKey: 'event:34'),
    );

    await markLatestRead(146);

    verifyNever(chatRepo.markRead(any, studentId: anyNamed('studentId')));
  });

  test('no chat item for it, or no result: nothing is sent', () async {
    dashboardWith(latest: _result());
    await markLatestRead(146);
    dashboardWith();
    await markLatestRead(146);

    verifyNever(chatRepo.markRead(any, studentId: anyNamed('studentId')));
  });

  test('Home can\'t be reached: fails, nothing is sent', () async {
    when(
      homeRepo.getChildDashboard(any),
    ).thenAnswer((_) async => const Failure(exception: NetworkException()));

    expect(await markLatestRead(146), isFailure<NetworkException>());
    verifyNever(chatRepo.markRead(any, studentId: anyNamed('studentId')));
  });
}
