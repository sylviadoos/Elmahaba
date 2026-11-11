import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';

/// The announcements loaded so far (pages 1 to [page] of [lastPage]),
/// newest first.
class AnnouncementsPageEntity extends Equatable {
  const AnnouncementsPageEntity({
    required this.items,
    required this.page,
    required this.lastPage,
    required this.total,
    required this.unread,
  });

  final List<AnnouncementEntity> items;
  final int page;
  final int lastPage;

  /// All of them, loaded or not.
  final int total;

  /// Those the parent hasn't read yet.
  final int unread;

  bool get hasMore => page < lastPage;

  /// These, then [next]'s items (any already here skipped), with [next]'s
  /// paging.
  AnnouncementsPageEntity followedBy(AnnouncementsPageEntity next) {
    final loaded = {for (final item in items) item.id};
    return AnnouncementsPageEntity(
      items: [
        ...items,
        for (final item in next.items)
          if (!loaded.contains(item.id)) item,
      ],
      page: next.page,
      lastPage: next.lastPage,
      total: next.total,
      unread: next.unread,
    );
  }

  @override
  List<Object?> get props => [items, page, lastPage, total, unread];
}
