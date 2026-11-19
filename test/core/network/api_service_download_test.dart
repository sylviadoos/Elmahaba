import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';

/// A server that sends [bytes] with [status], or breaks off once it has
/// sent [breakAfter] of them.
class _FakeServer implements HttpClientAdapter {
  _FakeServer(this.bytes, {this.status = 200, this.breakAfter});

  final List<int> bytes;
  final int status;
  final int? breakAfter;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final cut = breakAfter;
    final stream = cut == null
        ? Stream.value(Uint8List.fromList(bytes))
        : Stream<Uint8List>.fromFutures([
            Future.value(Uint8List.fromList(bytes.sublist(0, cut))),
            Future.error(const SocketException('Connection reset')),
          ]);
    return ResponseBody(stream, status);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Directory folder;
  late String savePath;

  setUp(() async {
    folder = await Directory.systemTemp.createTemp('download_test');
    addTearDown(() => folder.delete(recursive: true));
    savePath = '${folder.path}/77_trip-form.pdf';
  });

  ApiService serving(_FakeServer server) => ApiService(
    Dio(BaseOptions(baseUrl: 'https://school.test/'))
      ..httpClientAdapter = server,
  );

  /// What's left in the folder, by name.
  List<String> left() =>
      folder.listSync().map((file) => file.uri.pathSegments.last).toList();

  test('all of it came: the file, under its name, and nothing else', () async {
    final bytes = List.generate(5000, (i) => i % 256);

    await serving(_FakeServer(bytes)).download('files/77', savePath);

    expect(await File(savePath).readAsBytes(), bytes);
    expect(left(), ['77_trip-form.pdf']);
  });

  test('broken off halfway: nothing that looks downloaded', () async {
    final bytes = List.generate(5000, (i) => i % 256);

    await expectLater(
      serving(
        _FakeServer(bytes, breakAfter: 1000),
      ).download('files/77', savePath),
      throwsA(isA<AppException>()),
    );

    expect(File(savePath).existsSync(), isFalse);
  });

  test('the server refused it: nothing at all', () async {
    await expectLater(
      serving(
        _FakeServer(const [1, 2, 3], status: 404),
      ).download('files/77', savePath),
      throwsA(isA<AppException>()),
    );

    expect(left(), isEmpty);
  });

  test(
    'the same file twice at once: whole, not written into each other',
    () async {
      final bytes = List.generate(20000, (i) => i % 256);
      final api = serving(_FakeServer(bytes));

      await Future.wait([
        api.download('files/77', savePath),
        api.download('files/77', savePath),
      ]);

      expect(await File(savePath).readAsBytes(), bytes);
      expect(left(), ['77_trip-form.pdf']);
    },
  );
}
