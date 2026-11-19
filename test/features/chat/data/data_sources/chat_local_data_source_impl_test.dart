import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_local_data_source_impl.dart';

import '../../chat_fixtures.dart';

void main() {
  late ChatLocalDataSourceImpl local;

  setUp(() => local = ChatLocalDataSourceImpl());

  final first = schoolItem('message:41', about: omar);
  final second = schoolItem('message:42', about: omar);

  test('read since it was kept: opened again, it shows read', () {
    local.saveNewestPage(omar.studentId, chatPage([first, second]));

    local.markRead(omar.studentId, {'message:41'}, unread: 1);

    final kept = local.newestPage(omar.studentId)!;
    expect(kept.items.map((item) => item.isRead), [true, false]);
    expect(kept.unread, 1);
  });

  test("only that child's: the same item stays new on another's", () {
    local
      ..saveNewestPage(omar.studentId, chatPage([first]))
      ..saveNewestPage(null, chatPage([first]));

    local.markRead(omar.studentId, {'message:41'}, unread: 0);

    expect(local.newestPage(omar.studentId)!.items.single.isRead, isTrue);
    expect(local.newestPage(null)!.items.single.isRead, isFalse);
  });

  test('nothing kept for them: nothing to do', () {
    local.markRead(omar.studentId, {'message:41'}, unread: 0);

    expect(local.newestPage(omar.studentId), isNull);
  });
}
