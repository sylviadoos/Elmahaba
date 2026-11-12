import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/chat/domain/repos/chat_repo.dart';
import 'package:al_mahhaba_school/features/home/domain/repos/home_repo.dart';

/// Tells the school the parent has seen the child's latest result, so Home
/// stops calling it new: `await markLatestResultRead(child.studentId);`
///
/// Home's dashboard says which result is new and the chat item that says
/// so; reading that item is what makes it seen. Nothing is sent when it's
/// read already, or the school made no chat item for it.
@lazySingleton
class MarkLatestResultReadUseCase {
  MarkLatestResultReadUseCase(this._homeRepo, this._chatRepo);

  final HomeRepo _homeRepo;
  final ChatRepo _chatRepo;

  Future<Result<void>> call(int childId) async {
    final dashboard = await _homeRepo.getChildDashboard(childId);
    return dashboard.andThen<void>((dashboard) async {
      final latest = dashboard.latestResult;
      if (latest == null) return const Success(data: null);
      // `results.items` is where "new" comes from on Home, and the one
      // under `results.latest` may say nothing about it.
      final listed = dashboard.results.items
          .where((result) => result.id == latest.id)
          .firstOrNull;
      final isRead = listed?.isRead ?? latest.isRead;
      final chatKey = listed?.chatKey ?? latest.chatKey;
      if (isRead || chatKey == null) return const Success(data: null);
      final marked = await _chatRepo.markRead([chatKey]);
      return marked.map((_) {});
    });
  }
}
