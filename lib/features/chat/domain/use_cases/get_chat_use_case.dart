import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_page_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/repos/chat_repo.dart';

/// The chat, newest first by page:
/// `final result = await getChat(studentId: child.studentId);`, then
/// `getChat(studentId: …, before: page.nextBefore)` for the older ones,
/// `getChat(studentId: …, limit: 5)` for just the latest. [cancel] stops it
/// when it's no longer needed.
@lazySingleton
class GetChatUseCase {
  GetChatUseCase(this._repo);

  final ChatRepo _repo;

  Future<Result<ChatPageEntity>> call({
    int? studentId,
    String? before,
    int? limit,
    CancelHandle? cancel,
  }) => _repo.getChat(
    studentId: studentId,
    before: before,
    limit: limit,
    cancel: cancel,
  );
}
