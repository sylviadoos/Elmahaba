import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/chat/domain/repos/chat_repo.dart';

/// Marks the chat items the parent saw as read; the result is what's still
/// unread: `final result = await markChatRead([item.key]);`
@lazySingleton
class MarkChatReadUseCase {
  MarkChatReadUseCase(this._repo);

  final ChatRepo _repo;

  Future<Result<int>> call(List<String> keys) => _repo.markRead(keys);
}
