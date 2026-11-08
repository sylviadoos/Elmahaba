import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_subject_entity.dart';

/// The homework loaded so far (pages 1 to [page] of [lastPage]), newest
/// given first.
class HomeworkPageEntity extends Equatable {
  const HomeworkPageEntity({
    required this.items,
    required this.page,
    required this.lastPage,
    required this.total,
    required this.unread,
    this.subjects = const [],
  });

  final List<HomeworkEntity> items;
  final int page;
  final int lastPage;

  /// All the homework listed, loaded or not.
  final int total;

  /// The child's homework the parent hasn't read yet.
  final int unread;

  /// The subjects the child has homework in.
  final List<HomeworkSubjectEntity> subjects;

  bool get hasMore => page < lastPage;

  /// These, then [next]'s items (any already here skipped), with [next]'s
  /// paging.
  HomeworkPageEntity followedBy(HomeworkPageEntity next) {
    final loaded = {for (final item in items) item.id};
    return HomeworkPageEntity(
      items: [
        ...items,
        for (final item in next.items)
          if (!loaded.contains(item.id)) item,
      ],
      page: next.page,
      lastPage: next.lastPage,
      total: next.total,
      unread: next.unread,
      subjects: subjects,
    );
  }

  @override
  List<Object?> get props => [items, page, lastPage, total, unread, subjects];
}
