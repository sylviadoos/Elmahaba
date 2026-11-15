import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/complaints/domain/entities/new_complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/picked_attachment.dart';

const _megabyte = 1024 * 1024;

PickedAttachment _file(
  String name, {
  int megabytes = 1,
  AttachmentProblem? problem,
}) => PickedAttachment(
  name: name,
  path: '/files/$name',
  size: megabytes * _megabyte,
  problem: problem,
);

void main() {
  test('the extension, in lower case', () {
    expect(_file('Report.PDF').extension, 'pdf');
    expect(_file('notes').extension, isEmpty);
  });

  group('what can be sent', () {
    final ok = _file('a.pdf');
    final tooLarge = _file(
      'b.pdf',
      megabytes: 46,
      problem: AttachmentProblem.tooLarge,
    );

    test('only the files without a problem', () {
      expect([ok, tooLarge].valid, [ok]);
      expect([ok, tooLarge].validBytes, _megabyte);
      expect([ok, tooLarge].allInvalid, isFalse);
      expect([tooLarge].allInvalid, isTrue);
      expect(<PickedAttachment>[].allInvalid, isFalse);
    });

    test('the ones that won\'t go take no room', () {
      expect([ok, tooLarge].roomLeft, ComplaintAttachmentRules.maxFiles - 1);
    });
  });

  group('room for more', () {
    test('five files: none', () {
      final five = [for (var i = 0; i < 5; i++) _file('$i.jpg')];
      expect(five.roomLeft, 0);
      expect(five.canAddMore, isFalse);
    });

    test('the 25 MB used: none, though fewer than five', () {
      final full = [
        _file('a.pdf', megabytes: 10),
        _file('b.pdf', megabytes: 10),
        _file('c.pdf', megabytes: 5),
      ];
      expect(full.bytesLeft, 0);
      expect(full.roomLeft, 2);
      expect(full.canAddMore, isFalse);
    });

    test('what\'s left of the total', () {
      expect([_file('a.pdf', megabytes: 10)].bytesLeft, 15 * _megabyte);
    });
  });

  test('a file the school refused is marked, by its name', () {
    final files = [_file('a.pdf'), _file('b.docx')].rejecting('b.docx');
    expect(files.first.isValid, isTrue);
    expect(files.last.problem, AttachmentProblem.rejected);
    expect(files.valid, hasLength(1));
  });

  test('progress: the text first, then each file in turn', () {
    final first = _file('a.pdf', megabytes: 2);
    final second = _file('b.pdf', megabytes: 2);
    final skipped = _file('c.mp4', problem: AttachmentProblem.typeNotAllowed);
    // 1 MB of text and headers, then the two files.
    final total = 5 * _megabyte;
    final files = [first, skipped, second];

    final atStart = files.uploadProgress((sent: _megabyte, total: total));
    expect(atStart, {first: 0.0, second: 0.0});

    final halfway = files.uploadProgress((sent: 2 * _megabyte, total: total));
    expect(halfway, {first: 0.5, second: 0.0});

    final secondGoing = files.uploadProgress((
      sent: 4 * _megabyte,
      total: total,
    ));
    expect(secondGoing, {first: 1.0, second: 0.5});

    final done = files.uploadProgress((sent: total, total: total));
    expect(done, {first: 1.0, second: 1.0});
  });
}
