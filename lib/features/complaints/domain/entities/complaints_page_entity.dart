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
