import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/complaints/data/data_sources/complaints_local_data_source.dart';
import 'package:al_mahhaba_school/features/complaints/data/data_sources/complaints_remote_data_source.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_reply_model.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/new_complaint_model.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_attachment_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_category_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_details_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_reply_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaints_page_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/new_complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/repos/complaints_repo.dart';

@LazySingleton(as: ComplaintsRepo)
class ComplaintsRepoImpl implements ComplaintsRepo {
  ComplaintsRepoImpl(this._remoteDataSource, this._localDataSource);

  final ComplaintsRemoteDataSource _remoteDataSource;

  /// How far the parent has read them, for the dot on Complaints.
  final ComplaintsLocalDataSource _localDataSource;

  @override
  Future<Result<List<ComplaintCategoryEntity>>> getCategories() =>
      Result.guard(_remoteDataSource.getCategories);

  @override
  Future<Result<ComplaintsPageEntity>> getComplaints({required int page}) =>
      Result.guard(() => _remoteDataSource.getComplaints(page: page));

  @override
  Future<Result<ComplaintEntity>> sendComplaint(
    NewComplaintEntity complaint, {
    UploadProgressCallback? onProgress,
  }) => Result.guard(() async {
    final sent = await _remoteDataSource.sendComplaint(
      NewComplaintModel.fromEntity(complaint),
      onProgress: onProgress,
    );
    await _rememberOwnUpdate(sent);
    return sent;
  });

  @override
  Future<Result<ComplaintDetailsEntity>> getComplaint(int complaintId) =>
      Result.guard(() => _remoteDataSource.getComplaint(complaintId));

  @override
  Future<Result<ComplaintDetailsEntity>> sendReply(
    int complaintId,
    ComplaintReplyEntity reply, {
    UploadProgressCallback? onProgress,
  }) => Result.guard(() async {
    final details = await _remoteDataSource.sendReply(
      complaintId,
      ComplaintReplyModel.fromEntity(reply),
      onProgress: onProgress,
    );
    await _rememberOwnUpdate(details.complaint);
    return details;
  });

  /// The parent just changed [complaint] themselves, which is no news to
  /// them: that change puts no dot on Complaints.
  Future<void> _rememberOwnUpdate(ComplaintEntity complaint) async {
    final lastUpdate = complaint.lastUpdate;
    if (lastUpdate == null) return;
    await _localDataSource.saveOwnUpdates({
      ..._localDataSource.getOwnUpdates(),
      complaint.id: lastUpdate,
    });
  }

  @override
  Future<Result<bool>> hasNewComplaintUpdates() => Result.guard(() async {
    final page = await _remoteDataSource.getComplaints(page: 1);
    // Never opened on this phone: whatever is there is unread.
    final seen = _localDataSource.getSeenUpdate();
    final own = _localDataSource.getOwnUpdates();
    return page.complaints.any((complaint) {
      final lastUpdate = complaint.lastUpdate;
      if (lastUpdate == null) return false;
      if (seen != null && !lastUpdate.isAfter(seen)) return false;
      // The parent's own complaint or reply, unless the school has
      // changed it again since.
      final mine = own[complaint.id];
      return mine == null || lastUpdate.isAfter(mine);
    });
  });

  @override
  Future<void> markComplaintsSeen(DateTime? updatedAt) async {
    if (updatedAt == null) return;
    await _localDataSource.saveSeenUpdate(updatedAt);
    // Read up to there: only the parent's changes after it still matter.
    final own = _localDataSource.getOwnUpdates();
    final later = {
      for (final MapEntry(:key, :value) in own.entries)
        if (value.isAfter(updatedAt)) key: value,
    };
    if (later.length != own.length) {
      await _localDataSource.saveOwnUpdates(later);
    }
  }

  @override
  Future<Result<String>> downloadAttachment(
    int complaintId,
    ComplaintAttachmentEntity attachment,
  ) => Result.guard(
    () => _remoteDataSource.downloadAttachment(complaintId, attachment),
  );
}
