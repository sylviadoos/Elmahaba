import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/chat/domain/entities/chat_read_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/repos/chat_repo.dart';

/// Each time the school confirms items were read, on any page: for which
/// child, and what's still unread: `watchChatReads().listen((read) => …);`
@lazySingleton
class WatchChatReadsUseCase {
  WatchChatReadsUseCase(this._repo);

  final ChatRepo _repo;

  Stream<ChatReadEntity> call() => _repo.onMarkedRead;
}
