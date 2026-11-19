import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import 'package:al_mahhaba_school/core/image/photo_compressor.dart';
import 'package:al_mahhaba_school/core/utils/temp_files.dart';

@LazySingleton(as: PhotoCompressor)
class PhotoCompressorImpl implements PhotoCompressor {
  /// Names the copies apart when several are made in the same instant.
  int _made = 0;

  @override
  Future<CompressedPhoto?> compress(String path) async {
    try {
      final side = await _shortSide(path);
      final temp = await getTemporaryDirectory();
      final folder = Directory('${temp.path}/${TempFiles.compressedPhotos}');
      await folder.create(recursive: true);
      final target =
          '${folder.path}/${DateTime.now().microsecondsSinceEpoch}_'
          '${_made++}.jpg';
      final file = await FlutterImageCompress.compressAndGetFile(
        path,
        target,
        // It sizes by the short side, whichever way the photo is turned.
        minWidth: side,
        minHeight: side,
        quality: PhotoCompression.quality,
        // Where it was taken, the phone, the time: not sent.
        keepExif: false,
      );
      if (file == null) return null;
      return (path: file.path, size: await file.length());
    } catch (e) {
      debugPrint('Compressing $path: $e');
      return null;
    }
  }

  /// The short side the photo at [path] is made, read from its header
  /// (not the whole photo); a phone camera's 4:3 when it can't be read.
  static Future<int> _shortSide(String path) async {
    try {
      final buffer = await ui.ImmutableBuffer.fromFilePath(path);
      try {
        final descriptor = await ui.ImageDescriptor.encoded(buffer);
        try {
          return PhotoCompression.shortSideFor(
            descriptor.width,
            descriptor.height,
          );
        } finally {
          descriptor.dispose();
        }
      } finally {
        buffer.dispose();
      }
    } catch (_) {
      return PhotoCompression.shortSideFor(4000, 3000);
    }
  }
}
