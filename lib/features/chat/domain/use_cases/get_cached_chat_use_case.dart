import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/chat/domain/entities/chat_page_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/repos/chat_repo.dart';

/// The newest page of a chat as it last loaded, to show at once while it
/// loads again: `final shown = getCachedChat(child.studentId);` (null when
/// it hasn't loaded since the app started).
@lazySingleton
class GetCachedChatUseCase {
  GetCachedChatUseCase(this._repo);

  final ChatRepo _repo;

  ChatPageEntity? call(int? studentId) => _repo.cachedChat(studentId);
}
