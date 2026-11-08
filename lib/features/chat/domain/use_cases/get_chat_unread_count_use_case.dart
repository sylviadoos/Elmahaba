import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/chat/domain/repos/chat_repo.dart';

/// How many chat items the parent hasn't read (the badge on Chat):
/// `final result = await getChatUnreadCount();`
@lazySingleton
class GetChatUnreadCountUseCase {
  GetChatUnreadCountUseCase(this._repo);

  final ChatRepo _repo;

  Future<Result<int>> call() => _repo.getUnreadCount();
}
