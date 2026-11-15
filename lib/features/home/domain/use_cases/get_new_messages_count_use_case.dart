import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/home/domain/extensions/dashboard_chat_counts.dart';
import 'package:al_mahhaba_school/features/home/domain/repos/home_repo.dart';

/// What the School chat card on Home says is new for one child — its
/// [DashboardChatCounts.unreadChat], from their dashboard — so the badge on
/// Chat says the same: `final result = await getNewMessagesCount(9);`
///
/// Not the chat's own `unread-count`: it counts differently, so the two
/// numbers didn't match.
@lazySingleton
class GetNewMessagesCountUseCase {
  GetNewMessagesCountUseCase(this._repo);

  final HomeRepo _repo;

  Future<Result<int>> call(int childId) async => (await _repo.getChildDashboard(
    childId,
  )).map((dashboard) => dashboard.unreadChat.total);
}
