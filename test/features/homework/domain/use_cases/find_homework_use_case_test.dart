import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_page_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/use_cases/find_homework_use_case.dart';

import '../../../../helpers/result_dummy.dart';
import '../../homework_fixtures.dart';
import '../../homework_mocks.mocks.dart';

void main() {
  late MockHomeworkRepo repo;
  late FindHomeworkUseCase findHomework;

  setUpAll(() => provideResultDummy<HomeworkPageEntity>());

  setUp(() {
    repo = MockHomeworkRepo();
    findHomework = FindHomeworkUseCase(repo);
  });

  /// [page] of Omar's homework answers [result].
  void pageIs(int page, Result<HomeworkPageEntity> result) => when(
    repo.getHomework(omar.studentId, page: page, cancel: anyNamed('cancel')),
  ).thenAnswer((_) async => result);

  test('on the first page: found there, nothing more asked', () async {
    pageIs(1, Success(data: homeworkPage([exercise, reading], lastPage: 3)));

    final result = await findHomework(omar.studentId, reading.id);

    expect((result as Success).data, reading);
    verify(
      repo.getHomework(any, page: anyNamed('page'), cancel: anyNamed('cancel')),
    ).called(1);
  });

  test('further back: the pages after it, until it comes', () async {
    pageIs(1, Success(data: homeworkPage([exercise], lastPage: 2)));
    pageIs(2, Success(data: homeworkPage([reading], page: 2, lastPage: 2)));

    final result = await findHomework(omar.studentId, reading.id);

    expect((result as Success).data, reading);
  });

  test('nowhere (deleted): null, once the last page is through', () async {
    pageIs(1, Success(data: homeworkPage([exercise], lastPage: 2)));
    pageIs(2, Success(data: homeworkPage([reading], page: 2, lastPage: 2)));

    final result = await findHomework(omar.studentId, 999);

    expect((result as Success).data, isNull);
  });

  test("a page didn't load: its error", () async {
    pageIs(1, const Failure(exception: NetworkException()));

    final result = await findHomework(omar.studentId, reading.id);

    expect((result as Failure).exception, isA<NetworkException>());
  });
}
