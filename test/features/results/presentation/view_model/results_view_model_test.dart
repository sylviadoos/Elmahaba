import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/use_cases/get_latest_result_use_case.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_event.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_view_model.dart';

import '../../../../helpers/base_state_matchers.dart';
import '../../../../helpers/result_dummy.dart';
import '../../results_mocks.mocks.dart';

const _childId = 1201;
const _chatKey = 'event:34';

const _details = ResultDetailsEntity(
  id: 280,
  title: 'FINAL RESULT',
  academicYear: '2026-2027',
  resultType: 'value',
  studentName: 'Rovanio',
  subjectsIncluded: [],
  subjectsNotIncluded: [],
  highLevel: [],
  activities: [],
);

void main() {
  late MockGetLatestResultUseCase getLatest;
  late MockMarkChatReadUseCase markRead;
  late ResultsViewModel viewModel;

  setUpAll(() {
    provideResultDummy<LatestResult?>();
    provideResultDummy<int>();
  });

  setUp(() {
    getLatest = MockGetLatestResultUseCase();
    markRead = MockMarkChatReadUseCase();
    when(markRead(any)).thenAnswer((_) async => const Success(data: 0));
    viewModel = ResultsViewModel(getLatest, markRead);
  });

  tearDown(() => viewModel.close());

  /// The school's answer for the child's latest result.
  void answerWith({required bool isRead, String? chatKey = _chatKey}) =>
      when(getLatest(any)).thenAnswer(
        (_) async => Success(
          data: (details: _details, isRead: isRead, chatKey: chatKey),
        ),
      );

  /// Shows the result and lets the marking that follows it run.
  Future<void> show() async {
    await viewModel.doAction(const LoadLatestResultEvent(_childId));
    await Future<void>.delayed(Duration.zero);
  }

  test('a result the parent has not seen: the school is told, so Home stops '
      'calling it new', () async {
    answerWith(isRead: false);

    await show();

    expect(viewModel.state, isSuccessState(_details));
    verify(markRead([_chatKey])).called(1);
  });

  test('one already read: nothing is sent', () async {
    answerWith(isRead: true);

    await show();

    verifyNever(markRead(any));
  });

  test('one the school made no chat item for: nothing to mark', () async {
    answerWith(isRead: false, chatKey: null);

    await show();

    expect(viewModel.state, isSuccessState(_details));
    verifyNever(markRead(any));
  });

  test('no result published yet: nothing shown, nothing sent', () async {
    when(getLatest(any)).thenAnswer((_) async => const Success(data: null));

    await show();

    expect(viewModel.state, isSuccessState(isNull));
    verifyNever(markRead(any));
  });

  test('marking it read failed: the result still shows', () async {
    answerWith(isRead: false);
    when(
      markRead(any),
    ).thenAnswer((_) async => const Failure(exception: NetworkException()));

    await show();

    expect(viewModel.state, isSuccessState(_details));
  });

  test("couldn't load it: the error shows, nothing is marked", () async {
    when(
      getLatest(any),
    ).thenAnswer((_) async => const Failure(exception: NetworkException()));

    await show();

    expect(viewModel.state, isErrorState<NetworkException>());
    verifyNever(markRead(any));
  });
}
