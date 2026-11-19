import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_filter.dart';

/// What the parent does on Homework, sent to `HomeworkBloc`.
sealed class HomeworkIntent {
  const HomeworkIntent();
}

/// The parent's children, as the app has them now: when the page opens,
/// then each time they change. It shows [preferredId]'s homework at first
/// (the child it was opened on, else the one every page shows), else the
/// first child's.
final class HomeworkChildrenIntent extends HomeworkIntent {
  const HomeworkChildrenIntent(
    this.children, {
    required this.isLoading,
    this.preferredId,
  });

  /// Null until they first load.
  final List<ChildEntity>? children;
  final bool isLoading;
  final int? preferredId;
}

/// Shows the homework of the child with [studentId], picked in the header:
/// every page shows them too.
final class ShowChildHomeworkIntent extends HomeworkIntent {
  const ShowChildHomeworkIntent(this.studentId);

  final int studentId;
}

/// One homework on its own page, the child with [studentId]'s: [homework]
/// when the parent tapped it on Home (shown as it is), else found by
/// [homeworkId] — the chat names it, but doesn't carry it.
final class ShowOneHomeworkIntent extends HomeworkIntent {
  const ShowOneHomeworkIntent({
    required this.studentId,
    required this.homeworkId,
    this.homework,
  });

  final int? studentId;
  final int homeworkId;
  final HomeworkEntity? homework;
}

/// Lists the homework [filter] picks.
final class FilterHomeworkIntent extends HomeworkIntent {
  const FilterHomeworkIntent(this.filter);

  final HomeworkFilter filter;
}

/// Lists the homework in the subject [subjectId]; null for every subject.
final class PickHomeworkSubjectIntent extends HomeworkIntent {
  const PickHomeworkSubjectIntent(this.subjectId);

  final int? subjectId;
}

/// Loads it all again: "Try again", or pulled down.
final class ReloadHomeworkIntent extends HomeworkIntent {
  const ReloadHomeworkIntent();
}

/// Loads the next page (the list scrolled near its end).
final class LoadMoreHomeworkIntent extends HomeworkIntent {
  const LoadMoreHomeworkIntent();
}

/// Unread homework came on screen: its chat item is marked read (with the
/// others seen about then, in one request).
final class HomeworkSeenIntent extends HomeworkIntent {
  const HomeworkSeenIntent(this.chatKey);

  final String chatKey;
}

/// Downloads a homework file, to open it.
final class OpenHomeworkFileIntent extends HomeworkIntent {
  const OpenHomeworkFileIntent(this.attachment);

  final ChatAttachmentEntity attachment;
}

/// A homework photo came on screen, or "Try again" on one that didn't
/// load: it's saved on the phone to show. Nothing when it's saved or on
/// its way already.
final class LoadHomeworkImageIntent extends HomeworkIntent {
  const LoadHomeworkImageIntent(this.attachment);

  final ChatAttachmentEntity attachment;
}
