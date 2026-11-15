import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_due_status.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_filter.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_page_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_subject_entity.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/homework/presentation/widgets/homework_card.dart';
import 'package:al_mahhaba_school/features/homework/presentation/widgets/homework_list.dart';

import '../../homework_fixtures.dart';
import 'homework_page_harness.dart';

/// Everything as long as the school might send it: to see nothing
/// overflows on a small phone, in Arabic, with big text.
final _long = HomeworkEntity(
  id: 30,
  title:
      'Revise the whole of unit three and solve every exercise at the end '
      'of each lesson',
  subject: 'Social Studies and National Education',
  subjectId: 9,
  description:
      'Read pages 40 to 58 carefully, underline the key words, then answer '
      'the questions in your notebook. Bring the notebook on Sunday.',
  issueDate: DateTime(2026, 11, 2),
  dueDate: DateTime(2026, 11, 4),
  dueStatus: HomeworkDueStatus.past,
  isEdited: true,
  attachments: const [
    ChatAttachmentEntity(
      id: 90,
      fileName: 'unit-three-revision-worksheet-with-all-exercises-final.pdf',
      mimeType: 'application/pdf',
      size: 4815162,
      isAvailable: true,
    ),
  ],
  chatKey: 'event:50',
  isRead: false,
);

/// More subjects than fit across.
const _manySubjects = [
  math,
  arabic,
  HomeworkSubjectEntity(id: 7, name: 'Science'),
  HomeworkSubjectEntity(id: 2, name: 'English'),
  HomeworkSubjectEntity(id: 9, name: 'Social Studies and National Education'),
  HomeworkSubjectEntity(id: 11, name: 'Information Technology'),
];

void main() {
  late HomeworkPageHarness harness;

  setUp(() => (harness = HomeworkPageHarness()).register());
  tearDown(getIt.reset);

  /// Scrolls through every card, so each is built (and laid out) once.
  Future<void> scrollToTheEnd(WidgetTester tester) async {
    final list = find.byType(Scrollable).last;
    for (var i = 0; i < 12; i++) {
      await tester.drag(list, const Offset(0, -300));
      await tester.pump();
    }
  }

  group('fits', () {
    for (final (name, locale, size, textScale) in [
      ('the design\'s phone, English', const Locale('en'), designPhone, 1.0),
      ('the design\'s phone, Arabic', const Locale('ar'), designPhone, 1.0),
      ('a small phone, big text, English', const Locale('en'), smallPhone, 1.3),
      ('a small phone, big text, Arabic', const Locale('ar'), smallPhone, 1.3),
    ]) {
      testWidgets('$name: long homework, many subjects', (tester) async {
        harness.homeworkIs(
          homeworkPage(
            [_long, exercise, reading, _long.copy(id: 31)],
            unread: 2,
            subjects: _manySubjects,
          ),
        );
        // A layout that doesn't fit fails the test by itself (a "RenderFlex
        // overflowed" error).
        await harness.pump(
          tester,
          locale: locale,
          size: size,
          textScale: textScale,
        );
        final l10n = locale.languageCode == 'ar' ? ar : en;

        expect(find.text(l10n.homework), findsOneWidget);
        expect(find.text(l10n.allSubjects), findsOneWidget);
        expect(find.byType(HomeworkCard), findsWidgets);
        await scrollToTheEnd(tester);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('shows', () {
    testWidgets('the header: title, counts, the child, the filters', (
      tester,
    ) async {
      await harness.pump(tester);

      expect(find.text(en.homework), findsOneWidget);
      expect(
        find.text('${en.homeworkCount(2)} · ${en.newCount(1)}'),
        findsOneWidget,
      );
      expect(find.text('Omar Ahmed'), findsOneWidget);
      for (final label in [
        en.filterAll,
        en.homeworkDueSoon,
        en.homeworkUpcoming,
      ]) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('a card: subject, title, what to do, when due, the file', (
      tester,
    ) async {
      await harness.pump(tester);

      final card = find.ancestor(
        of: find.text('Ex 1'),
        matching: find.byType(HomeworkCard),
      );
      Finder inCard(String text) =>
          find.descendant(of: card, matching: find.text(text));
      expect(inCard('Math'), findsOneWidget);
      expect(inCard('Pages 1-3'), findsOneWidget);
      expect(inCard(en.homeworkNew), findsOneWidget);
      expect(inCard(en.homeworkDueOn('Wed 11 Nov')), findsOneWidget);
      expect(inCard('ex1.pdf'), findsOneWidget);
    });

    testWidgets('read and edited, with no due date', (tester) async {
      await harness.pump(tester);

      final card = find.ancestor(
        of: find.text('Read chapter 2'),
        matching: find.byType(HomeworkCard),
      );
      Finder inCard(String text) =>
          find.descendant(of: card, matching: find.text(text));
      expect(inCard(en.homeworkNoDueDate), findsOneWidget);
      expect(
        inCard('${en.homeworkGiven('Fri 6 Nov')} · ${en.edited}'),
        findsOneWidget,
      );
      expect(inCard(en.homeworkNew), findsNothing);
    });

    testWidgets('one subject: no subject chips, nothing to choose', (
      tester,
    ) async {
      harness.homeworkIs(homeworkPage([exercise], subjects: const [math]));
      await harness.pump(tester);

      expect(find.text(en.allSubjects), findsNothing);
    });

    testWidgets('loading: a spinner', (tester) async {
      when(
        harness.getHomework(
          any,
          filter: anyNamed('filter'),
          subjectId: anyNamed('subjectId'),
          page: anyNamed('page'),
          cancel: anyNamed('cancel'),
        ),
      ).thenAnswer((_) => Completer<Result<HomeworkPageEntity>>().future);
      await harness.pump(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(HomeworkCard), findsNothing);
    });

    testWidgets('none yet: says so', (tester) async {
      harness.homeworkIs(homeworkPage([], subjects: const []));
      await harness.pump(tester);

      expect(find.text(en.noHomework), findsOneWidget);
      expect(find.text(en.noHomeworkHint), findsOneWidget);
    });

    for (final (name, size) in [
      ('the design\'s phone', designPhone),
      ('a small phone', smallPhone),
    ]) {
      testWidgets('none yet, $name: in the middle of the space below the '
          'header', (tester) async {
        harness.homeworkIs(homeworkPage([], subjects: const []));
        await harness.pump(tester, size: size);

        final area = tester.getRect(find.byType(HomeworkList));
        final message = tester.getRect(find.byType(StateMessage));
        expect((message.center.dy - area.center.dy).abs(), lessThan(1));
      });
    }

    testWidgets('didn\'t load: in the middle too', (tester) async {
      harness.homeworkFails(const NetworkException());
      await harness.pump(tester);

      final area = tester.getRect(find.byType(HomeworkList));
      final message = tester.getRect(find.byType(StateMessage));
      expect((message.center.dy - area.center.dy).abs(), lessThan(1));
    });

    testWidgets('none for a filter: says so, another filter to try', (
      tester,
    ) async {
      await harness.pump(tester);
      harness.homeworkIs(homeworkPage([]));
      // The fifth chip: scrolled to, as the parent would.
      await tester.ensureVisible(find.text(en.homeworkPast));
      await tester.pump();
      await tester.tap(find.text(en.homeworkPast));
      await tester.pump();
      await tester.pump();

      expect(find.text(en.noHomeworkFiltered), findsOneWidget);
      expect(find.text(en.noHomeworkFilteredHint), findsOneWidget);
    });

    testWidgets('a read-only child: the school\'s reason, and Try again', (
      tester,
    ) async {
      harness.homeworkFails(
        const ServerException(
          statusCode: 403,
          code: 'read_only_child',
          message: 'This action is not available for this child.',
        ),
      );
      await harness.pump(tester);

      expect(
        find.text('This action is not available for this child.'),
        findsOneWidget,
      );
      harness.homeworkIs(homeworkPage([exercise]));
      await tester.tap(find.text(en.tryAgain));
      await tester.pump();
      await tester.pump();
      expect(find.text('Ex 1'), findsOneWidget);
    });
  });

  group('does', () {
    testWidgets('a filter: asks for it', (tester) async {
      await harness.pump(tester);
      await tester.tap(find.text(en.homeworkDueSoon));
      await tester.pump();

      verify(
        harness.getHomework(
          omar.studentId,
          filter: HomeworkFilter.dueSoon,
          cancel: anyNamed('cancel'),
        ),
      ).called(1);
    });

    testWidgets('a subject: asks for it', (tester) async {
      await harness.pump(tester);
      await tester.tap(find.text('Arabic').first);
      await tester.pump();

      verify(
        harness.getHomework(
          omar.studentId,
          subjectId: arabic.id,
          cancel: anyNamed('cancel'),
        ),
      ).called(1);
    });

    testWidgets('opened from the chat: on the child it showed', (tester) async {
      await harness.pump(tester, studentId: lina.studentId);

      expect(find.text('Lina Ahmed'), findsOneWidget);
      verify(
        harness.getHomework(lina.studentId, cancel: anyNamed('cancel')),
      ).called(1);
    });

    testWidgets('unread homework on screen: marked read', (tester) async {
      await harness.pump(tester);
      await tester.pump(const Duration(milliseconds: 500));

      verify(
        harness.markRead(['event:41'], studentId: omar.studentId),
      ).called(1);
    });

    testWidgets('a file tapped: downloaded, to open', (tester) async {
      when(
        harness.downloadAttachment(
          any,
          studentId: anyNamed('studentId'),
          cancel: anyNamed('cancel'),
        ),
      ).thenAnswer((_) async => const Failure(exception: NetworkException()));
      await harness.pump(tester);
      await tester.tap(find.text('ex1.pdf'));
      await tester.pump();

      verify(
        harness.downloadAttachment(
          exerciseFile,
          studentId: anyNamed('studentId'),
          cancel: anyNamed('cancel'),
        ),
      ).called(1);
    });
  });
}

extension on HomeworkEntity {
  /// The same homework, under another id.
  HomeworkEntity copy({required int id}) => HomeworkEntity(
    id: id,
    title: title,
    subject: subject,
    subjectId: subjectId,
    description: description,
    issueDate: issueDate,
    dueDate: dueDate,
    dueStatus: dueStatus,
    isEdited: isEdited,
    attachments: attachments,
    chatKey: '$chatKey-$id',
    isRead: isRead,
  );
}
