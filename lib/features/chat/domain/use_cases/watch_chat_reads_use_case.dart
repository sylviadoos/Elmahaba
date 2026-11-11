import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/chat/domain/repos/chat_repo.dart';

/// What's still unread each time the school confirms items were read, on
/// any page: `watchChatReads().listen((unread) => …);`
@lazySingleton
class WatchChatReadsUseCase {
  WatchChatReadsUseCase(this._repo);

  final ChatRepo _repo;

  Stream<int> call() => _repo.onMarkedRead;
}
