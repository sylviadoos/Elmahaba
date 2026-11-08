import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/homework/data/data_sources/homework_remote_data_source.dart';
import 'package:al_mahhaba_school/features/homework/data/models/homework_page_model.dart';
import 'package:al_mahhaba_school/features/homework/data/repos/homework_repo_impl.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_filter.dart';

import '../../../../helpers/result_matchers.dart';
import '../../homework_fixtures.dart';
import 'homework_repo_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<HomeworkRemoteDataSource>()])
void main() {
  late MockHomeworkRemoteDataSource remoteDataSource;
  late HomeworkRepoImpl repo;

  final page = HomeworkPageModel(
    items: [exercise],
    page: 1,
    lastPage: 2,
    total: 21,
    unread: 1,
  );

  setUp(() {
    remoteDataSource = MockHomeworkRemoteDataSource();
    repo = HomeworkRepoImpl(remoteDataSource);
  });

  test('getHomework: what the school sent, as asked', () async {
    when(
      remoteDataSource.getHomework(
        omar.studentId,
        filter: HomeworkFilter.past,
        subjectId: 5,
        page: 2,
        cancel: anyNamed('cancel'),
      ),
    ).thenAnswer((_) async => page);

    expect(
      await repo.getHomework(
        omar.studentId,
        filter: HomeworkFilter.past,
        subjectId: 5,
        page: 2,
      ),
      isSuccess<Object?>(page),
    );
  });

  test('getHomework: a failure, not a throw', () async {
    when(
      remoteDataSource.getHomework(
        any,
        filter: anyNamed('filter'),
        subjectId: anyNamed('subjectId'),
        page: anyNamed('page'),
        cancel: anyNamed('cancel'),
      ),
    ).thenThrow(const NetworkException());

    expect(
      await repo.getHomework(omar.studentId),
      isFailure<NetworkException>(),
    );
  });
}
