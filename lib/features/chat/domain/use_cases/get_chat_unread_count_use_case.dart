import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/chat/domain/repos/chat_repo.dart';

/// How many of a child's chat items the parent hasn't read (the badge on
/// Chat): `final result = await getChatUnreadCount(studentId: 146);`
@lazySingleton
class GetChatUnreadCountUseCase {
  GetChatUnreadCountUseCase(this._repo);

  final ChatRepo _repo;

  Future<Result<int>> call({required int studentId}) =>
      _repo.getUnreadCount(studentId: studentId);
}
