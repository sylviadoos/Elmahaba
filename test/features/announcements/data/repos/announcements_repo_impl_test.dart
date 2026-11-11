import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/announcements/data/data_sources/announcements_remote_data_source.dart';
import 'package:al_mahhaba_school/features/announcements/data/models/announcements_page_model.dart';
import 'package:al_mahhaba_school/features/announcements/data/repos/announcements_repo_impl.dart';

import '../../../../helpers/result_matchers.dart';
import '../../announcements_fixtures.dart';
import 'announcements_repo_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AnnouncementsRemoteDataSource>()])
void main() {
  late MockAnnouncementsRemoteDataSource remoteDataSource;
  late AnnouncementsRepoImpl repo;

  setUp(() {
    remoteDataSource = MockAnnouncementsRemoteDataSource();
    repo = AnnouncementsRepoImpl(remoteDataSource);
  });

  test('a page of them: what the school sent', () async {
    final page = AnnouncementsPageModel(
      items: [meeting],
      page: 2,
      lastPage: 3,
      total: 21,
      unread: 1,
    );
    when(
      remoteDataSource.getAnnouncements(
        omar.studentId,
        page: 2,
        cancel: anyNamed('cancel'),
      ),
    ).thenAnswer((_) async => page);

    expect(
      await repo.getAnnouncements(omar.studentId, page: 2),
      isSuccess(page),
    );
  });

  test('can\'t reach it: fails with the error', () async {
    when(
      remoteDataSource.getAnnouncements(
        any,
        page: anyNamed('page'),
        cancel: anyNamed('cancel'),
      ),
    ).thenThrow(const NetworkException());

    expect(
      await repo.getAnnouncements(omar.studentId),
      isFailure<NetworkException>(),
    );
  });
}
