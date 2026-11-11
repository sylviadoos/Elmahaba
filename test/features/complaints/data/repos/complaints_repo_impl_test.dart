import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_details_model.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_model.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaints_page_model.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_reply_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_status.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/new_complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/data/repos/complaints_repo_impl.dart';

import '../../../../helpers/result_matchers.dart';
import '../../complaints_fixtures.dart';
import '../../complaints_mocks.mocks.dart';

/// What the API answers for `GET /complaints?page=1`.
ComplaintsPageModel listing(List<DateTime?> updates) => ComplaintsPageModel(
  complaints: [
    for (final (index, lastUpdate) in updates.indexed)
      complaint(id: index + 1, lastUpdate: lastUpdate),
  ],
  page: 1,
  lastPage: 1,
  total: updates.length,
);

/// What the API answers once the parent sent complaint [id] or replied.
ComplaintModel sentComplaint({required int id, DateTime? lastUpdate}) =>
    ComplaintModel(
      id: id,
      reference: 'CMP-2026-000$id',
      categoryEn: 'Transport',
      categoryAr: 'النقل',
      childName: '',
      childNameAr: '',
      status: ComplaintStatus.submitted,
      isOpen: true,
      canReply: false,
      lastUpdate: lastUpdate,
    );

void main() {
  late MockComplaintsRemoteDataSource remoteDataSource;
  late MockComplaintsLocalDataSource localDataSource;
  late ComplaintsRepoImpl repo;

  final older = DateTime(2026, 11, 3, 9);
  final newer = DateTime(2026, 11, 8, 17, 30);

  setUp(() {
    remoteDataSource = MockComplaintsRemoteDataSource();
    localDataSource = MockComplaintsLocalDataSource();
    repo = ComplaintsRepoImpl(remoteDataSource, localDataSource);
  });

  void answerWith(List<DateTime?> updates) => when(
    remoteDataSource.getComplaints(page: anyNamed('page')),
  ).thenAnswer((_) async => listing(updates));

  group('hasNewComplaintUpdates', () {
    test('the school changed one since the parent looked: yes', () async {
      answerWith([older, newer]);
      when(localDataSource.getSeenUpdate()).thenReturn(older);

      expect(await repo.hasNewComplaintUpdates(), isSuccess(true));
      verify(remoteDataSource.getComplaints(page: 1)).called(1);
    });

    test('nothing changed since: no', () async {
      answerWith([older, newer]);
      when(localDataSource.getSeenUpdate()).thenReturn(newer);

      expect(await repo.hasNewComplaintUpdates(), isSuccess(false));
    });

    test('never opened on this phone: what is there is unread', () async {
      answerWith([older]);
      when(localDataSource.getSeenUpdate()).thenReturn(null);

      expect(await repo.hasNewComplaintUpdates(), isSuccess(true));
    });

    test('no complaints at all: no dot, whatever was saved', () async {
      answerWith([]);
      when(localDataSource.getSeenUpdate()).thenReturn(null);

      expect(await repo.hasNewComplaintUpdates(), isSuccess(false));
    });

    test("none of them says when it changed: nothing to compare", () async {
      answerWith([null, null]);
      when(localDataSource.getSeenUpdate()).thenReturn(null);

      expect(await repo.hasNewComplaintUpdates(), isSuccess(false));
    });

    test('asking the school failed: fails, the dot stays as it was', () async {
      when(
        remoteDataSource.getComplaints(page: anyNamed('page')),
      ).thenThrow(const NetworkException());

      expect(
        await repo.hasNewComplaintUpdates(),
        isFailure<NetworkException>(),
      );
    });
  });

  group('the parent'
      's own changes', () {
    test('their complaint, sent after they last looked: no dot', () async {
      answerWith([older, newer]);
      when(localDataSource.getSeenUpdate()).thenReturn(older);
      when(localDataSource.getOwnUpdates()).thenReturn({2: newer});

      expect(await repo.hasNewComplaintUpdates(), isSuccess(false));
    });

    test('the first complaint they ever sent: no dot', () async {
      answerWith([newer]);
      when(localDataSource.getSeenUpdate()).thenReturn(null);
      when(localDataSource.getOwnUpdates()).thenReturn({1: newer});

      expect(await repo.hasNewComplaintUpdates(), isSuccess(false));
    });

    test('the school changed it again since: a dot', () async {
      answerWith([older, newer]);
      when(localDataSource.getSeenUpdate()).thenReturn(older);
      when(
        localDataSource.getOwnUpdates(),
      ).thenReturn({2: newer.subtract(const Duration(hours: 1))});

      expect(await repo.hasNewComplaintUpdates(), isSuccess(true));
    });

    test('another one has a reply from the school: still a dot', () async {
      answerWith([newer, newer]);
      when(localDataSource.getSeenUpdate()).thenReturn(older);
      when(localDataSource.getOwnUpdates()).thenReturn({2: newer});

      expect(await repo.hasNewComplaintUpdates(), isSuccess(true));
    });

    test('sending a complaint remembers it as theirs', () async {
      when(localDataSource.getOwnUpdates()).thenReturn({3: older});
      when(
        remoteDataSource.sendComplaint(any, onProgress: anyNamed('onProgress')),
      ).thenAnswer((_) async => sentComplaint(id: 7, lastUpdate: newer));

      await repo.sendComplaint(
        const NewComplaintEntity(
          categoryId: 1,
          description: 'The bus',
          clientUuid: 'u1',
        ),
      );

      verify(localDataSource.saveOwnUpdates({3: older, 7: newer})).called(1);
    });

    test('replying remembers the reply as theirs', () async {
      when(localDataSource.getOwnUpdates()).thenReturn({});
      when(
        remoteDataSource.sendReply(
          any,
          any,
          onProgress: anyNamed('onProgress'),
        ),
      ).thenAnswer(
        (_) async => ComplaintDetailsModel(
          complaint: sentComplaint(id: 7, lastUpdate: newer),
          description: '',
          messages: const [],
          statusHistory: const [],
        ),
      );

      await repo.sendReply(
        7,
        const ComplaintReplyEntity(text: 'Thanks', clientUuid: 'u2'),
      );

      verify(localDataSource.saveOwnUpdates({7: newer})).called(1);
    });

    test('sending failed: nothing remembered', () async {
      when(
        remoteDataSource.sendComplaint(any, onProgress: anyNamed('onProgress')),
      ).thenThrow(const NetworkException());

      final result = await repo.sendComplaint(
        const NewComplaintEntity(
          categoryId: 1,
          description: 'The bus',
          clientUuid: 'u1',
        ),
      );

      expect(result, isFailure<NetworkException>());
      verifyNever(localDataSource.saveOwnUpdates(any));
    });
  });

  group('markComplaintsSeen', () {
    test('drops their changes it covers, keeps later ones', () async {
      final latest = newer.add(const Duration(days: 1));
      when(localDataSource.getOwnUpdates()).thenReturn({1: older, 2: latest});

      await repo.markComplaintsSeen(newer);

      verify(localDataSource.saveOwnUpdates({2: latest})).called(1);
    });

    test('keeps how far the parent has read', () async {
      await repo.markComplaintsSeen(newer);

      verify(localDataSource.saveSeenUpdate(newer)).called(1);
    });

    test('nothing to go by: leaves it as it was', () async {
      await repo.markComplaintsSeen(null);

      verifyNever(localDataSource.saveSeenUpdate(any));
    });
  });

  test('newestUpdate is the latest change across them', () {
    expect(complaintsPage([]).newestUpdate, isNull);
    expect(
      complaintsPage([
        complaint(id: 1, lastUpdate: older),
        complaint(id: 2),
        complaint(id: 3, lastUpdate: newer),
      ]).newestUpdate,
      newer,
    );
  });
}
