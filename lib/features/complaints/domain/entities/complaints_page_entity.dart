import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_entity.dart';

/// The parent's complaints loaded so far, newest first: pages 1 to [page]
/// of [lastPage].
class ComplaintsPageEntity extends Equatable {
  const ComplaintsPageEntity({
    required this.complaints,
    required this.page,
    required this.lastPage,
    required this.total,
  });

  final List<ComplaintEntity> complaints;
  final int page;
  final int lastPage;

  /// How many the parent has, loaded or not.
  final int total;

  bool get hasMore => page < lastPage;

  /// The newest change across them, which is how far the parent has read
  /// once these are on screen (the dot on the Complaints button). Null
  /// when there are none, or none says when it changed.
  DateTime? get newestUpdate {
    DateTime? newest;
    for (final complaint in complaints) {
      final lastUpdate = complaint.lastUpdate;
      if (lastUpdate == null) continue;
      if (newest == null || lastUpdate.isAfter(newest)) newest = lastUpdate;
    }
    return newest;
  }

  /// These, then [next]'s. One sent meanwhile pushes the older ones down a
  /// page, so any already here are skipped.
  ComplaintsPageEntity followedBy(ComplaintsPageEntity next) {
    final loaded = {for (final complaint in complaints) complaint.id};
    return ComplaintsPageEntity(
      complaints: [
        ...complaints,
        for (final complaint in next.complaints)
          if (!loaded.contains(complaint.id)) complaint,
      ],
      page: next.page,
      lastPage: next.lastPage,
      total: next.total,
    );
  }

  @override
  List<Object?> get props => [complaints, page, lastPage, total];
}
