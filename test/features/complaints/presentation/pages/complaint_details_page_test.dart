import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/widgets/page_refresher.dart';
import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_details_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_message_entity.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/pages/complaint_details_page.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/complaint_details_view_model.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/test_app.dart';
import '../../complaints_fixtures.dart';
import '../../complaints_mocks.mocks.dart';

/// Firebase isn't set up in tests: pushes arrive when [arrive] is called.
class _Pushes implements NotificationService {
  final _received = StreamController<Map<String, dynamic>>.broadcast();

  void arrive() => _received.add(const {'type': 'complaint'});

  Future<void> close() => _received.close();

  @override
  Stream<Map<String, dynamic>> get onReceived => _received.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

/// The complaint as the school last left it: with its [updates].
ComplaintDetailsEntity details(List<ComplaintMessageEntity> updates) =>
    ComplaintDetailsEntity(
      complaint: complaint(),
      description: 'The bus came late every day this week.',
      messages: updates,
      statusHistory: const [],
    );

const firstAnswer = ComplaintMessageEntity(
  id: 1,
  fromParent: false,
  senderName: 'Transport office',
  text: 'We are looking into it.',
  attachments: [],
);

const solved = ComplaintMessageEntity(
  id: 2,
  fromParent: false,
  senderName: 'Transport office',
  text: 'The driver was changed; it is solved.',
  attachments: [],
);

void main() {
  late MockGetComplaintDetailsUseCase getDetails;
  late _Pushes pushes;

  setUpAll(() => provideResultDummy<ComplaintDetailsEntity>());

  setUp(() {
    getDetails = MockGetComplaintDetailsUseCase();
    pushes = _Pushes();
    addTearDown(pushes.close);
    getIt
      ..registerFactory<ComplaintDetailsViewModel>(
        () => ComplaintDetailsViewModel(
          getDetails,
          MockSendComplaintReplyUseCase(),
          MockDownloadComplaintAttachmentUseCase(),
        ),
      )
      ..registerSingleton<NotificationService>(pushes);
  });
  tearDown(getIt.reset);

  /// The school answers each time it's asked, in turn (then the last
  /// again).
  void answers(List<Result<ComplaintDetailsEntity>> results) {
    var call = 0;
    when(getDetails(12)).thenAnswer(
      (_) async => results[call < results.length ? call++ : call - 1],
    );
  }

  Future<void> pump(WidgetTester tester) async {
    tester.usePhoneScreen();
    final router = GoRouter(
      initialLocation: AppRoutes.complaintDetailsOf(12),
      routes: [
        GoRoute(
          path: AppRoutes.complaintDetails,
          builder: (_, state) => ComplaintDetailsPage(
            complaintId: int.parse(state.pathParameters['id']!),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(TestApp(router: router));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('pulled down: what the school sent since shows', (tester) async {
    answers([
      Success(data: details(const [firstAnswer])),
      Success(data: details(const [firstAnswer, solved])),
    ]);
    await pump(tester);
    expect(find.text(solved.text), findsNothing);

    await tester.fling(
      find.byType(SingleChildScrollView),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    expect(find.text(solved.text), findsOneWidget);
    expect(find.text(firstAnswer.text), findsOneWidget);
    verify(getDetails(12)).called(2);
  });

  testWidgets('a notification while it shows: asked again, without leaving', (
    tester,
  ) async {
    answers([
      Success(data: details(const [firstAnswer])),
      Success(data: details(const [firstAnswer, solved])),
    ]);
    await pump(tester);

    pushes.arrive();
    await tester.pump(PageRefresher.notificationDelay);
    await tester.pump();
    await tester.pump();

    expect(find.text(solved.text), findsOneWidget);
  });

  testWidgets('asking again fails: what was shown stays', (tester) async {
    answers([
      Success(data: details(const [firstAnswer])),
      const Failure(exception: NetworkException()),
    ]);
    await pump(tester);

    pushes.arrive();
    await tester.pump(PageRefresher.notificationDelay);
    await tester.pump();
    await tester.pump();

    expect(find.text(firstAnswer.text), findsOneWidget);
  });
}
