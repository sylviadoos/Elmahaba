import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_pull_to_refresh.dart';

/// Pulling past the newest item of the chat asks for newer ones; the
/// list's other end and ordinary scrolling don't.
void main() {
  late int asked;
  late ScrollController scroll;

  setUp(() {
    asked = 0;
    scroll = ScrollController();
  });

  tearDown(() => scroll.dispose());

  /// The chat's list as the page has it: reversed, the newest at the
  /// bottom, where it opens.
  Future<void> pump(WidgetTester tester, {int items = 40}) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatPullToRefresh(
              onRefresh: () => asked++,
              child: ListView.builder(
                controller: scroll,
                reverse: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: items,
                itemBuilder: (_, i) =>
                    SizedBox(height: 60, child: Text('item $i')),
              ),
            ),
          ),
        ),
      );

  /// The finger up: past the newest, at the bottom.
  const pastNewest = Offset(0, -300);

  testWidgets(
    'at the newest, pulled past it: asks once',
    (tester) async {
      await pump(tester);

      await tester.drag(find.byType(ListView), pastNewest);
      await tester.pumpAndSettle();

      expect(asked, 1);
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );

  testWidgets(
    'a chat shorter than the screen: it can be pulled too',
    (tester) async {
      await pump(tester, items: 2);

      await tester.drag(find.byType(ListView), pastNewest);
      await tester.pumpAndSettle();

      expect(asked, 1);
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );

  testWidgets('a short pull: nothing', (tester) async {
    await pump(tester);

    await tester.drag(find.byType(ListView), const Offset(0, -40));
    await tester.pumpAndSettle();

    expect(asked, 0);
  });

  testWidgets('scrolling up to older ones and back down: nothing', (
    tester,
  ) async {
    await pump(tester);

    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(asked, 0);
    expect(scroll.offset, greaterThan(0));
  });

  testWidgets('two pulls: asks twice', (tester) async {
    await pump(tester);

    await tester.drag(find.byType(ListView), pastNewest);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), pastNewest);
    await tester.pumpAndSettle();

    expect(asked, 2);
  });
}
