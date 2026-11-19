import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/image/lighter_photo.dart';
import 'package:al_mahhaba_school/core/image/photo_compressor.dart';

import 'lighter_photo_test.mocks.dart';

const _megabyte = 1024 * 1024;

@GenerateNiceMocks([MockSpec<PhotoCompressor>()])
void main() {
  late MockPhotoCompressor compressor;

  setUp(() => compressor = MockPhotoCompressor());

  PickedFile picked(String name, {int size = 4 * _megabyte}) =>
      (name: name, path: '/picked/$name', size: size);

  void compressesTo(String path, int size) => when(
    compressor.compress(any),
  ).thenAnswer((_) async => (path: '/light/$path', size: size));

  group('a photo', () {
    test('sent made lighter, as a JPEG', () async {
      compressesTo('1.jpg', 400 * 1024);

      expect(await compressor.lighter(picked('IMG_2041.JPG')), (
        name: 'IMG_2041.jpg',
        path: '/light/1.jpg',
        size: 400 * 1024,
      ));
      verify(compressor.compress('/picked/IMG_2041.JPG')).called(1);
    });

    test('a PNG (a screenshot): a JPEG too', () async {
      compressesTo('2.jpg', 300 * 1024);

      expect(
        (await compressor.lighter(picked('report.png'))).name,
        'report.jpg',
      );
    });

    test('not any lighter so: sent as it was', () async {
      compressesTo('3.jpg', 90 * 1024);
      final small = picked('icon.png', size: 80 * 1024);

      expect(await compressor.lighter(small), small);
    });

    test("an iPhone's HEIC: always a JPEG, the school doesn't take it", () async {
      compressesTo('4.jpg', 5 * _megabyte);

      expect(await compressor.lighter(picked('IMG_9.heic', size: _megabyte)), (
        name: 'IMG_9.jpg',
        path: '/light/4.jpg',
        size: 5 * _megabyte,
      ));
    });

    test("can't be read as one: as it was, the checks say why", () async {
      when(compressor.compress(any)).thenAnswer((_) async => null);
      final renamed = picked('virus.jpg');

      expect(await compressor.lighter(renamed), renamed);
    });
  });

  test('a document: as it is, never compressed', () async {
    for (final name in ['letter.pdf', 'form.docx', 'old.doc']) {
      final document = picked(name);
      expect(await compressor.lighter(document), document);
    }
    verifyNever(compressor.compress(any));
  });

  group('the short side, for the long one to be 1920 px', () {
    test('a phone photo, either way turned: 1440', () {
      expect(PhotoCompression.shortSideFor(4000, 3000), 1440);
      expect(PhotoCompression.shortSideFor(3000, 4000), 1440);
    });

    test('a tall screenshot', () {
      expect(PhotoCompression.shortSideFor(1080, 2400), 864);
    });

    test('small enough already: its own, never made bigger', () {
      expect(PhotoCompression.shortSideFor(1600, 1200), 1200);
      expect(PhotoCompression.shortSideFor(1920, 1080), 1080);
    });

    test("no size read: the long side's", () {
      expect(PhotoCompression.shortSideFor(0, 0), 1920);
    });
  });
}
