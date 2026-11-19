import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_local_data_source.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_page_entity.dart';

@LazySingleton(as: ChatLocalDataSource)
class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  /// By the child's `studentId`; null for everything.
  final Map<int?, ChatPageEntity> _newest = {};

  @override
  ChatPageEntity? newestPage(int? studentId) => _newest[studentId];

  @override
  void saveNewestPage(int? studentId, ChatPageEntity page) =>
      _newest[studentId] = page;

  @override
  void markRead(int? studentId, Set<String> keys, {required int unread}) {
    final page = _newest[studentId];
    if (page == null) return;
    _newest[studentId] = page.withRead(keys, isRead: true, unread: unread);
  }

  @override
  void clear() => _newest.clear();
}
