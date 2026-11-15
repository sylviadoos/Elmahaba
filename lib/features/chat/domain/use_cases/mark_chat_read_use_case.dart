import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/chat/domain/repos/chat_repo.dart';

/// Marks the chat items the parent saw as read; the result is what's still
/// unread: `final result = await markChatRead([item.key]);`
///
/// On one child's page — homework, results, announcements — pass their
/// [studentId]: one item can be about two of the parent's children, and
/// reading it for one shouldn't take "new" off the other. The chat is all
/// the children at once, so it passes none.
@lazySingleton
class MarkChatReadUseCase {
  MarkChatReadUseCase(this._repo);

  final ChatRepo _repo;

  Future<Result<int>> call(List<String> keys, {int? studentId}) =>
      _repo.markRead(keys, studentId: studentId);
}
