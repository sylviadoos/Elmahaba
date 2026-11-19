import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// What the app leaves in its temporary folder, cleared as it starts (so
/// nothing is being picked or sent then).
abstract final class TempFiles {
  /// How long a file opened from a chat, complaint or excuse is kept, to
  /// open again without downloading it.
  static const Duration keepOpened = Duration(days: 7);

  /// Where the lighter copies of the photos picked to send are saved (see
  /// `PhotoCompressorImpl`): all cleared, like the picker's copies.
  static const String compressedPhotos = 'compressed_photos';

  /// Where those files are saved (see the remote data sources).
  static const List<String> _openedFolders = [
    'chat_attachments',
    'complaint_attachments',
    'excuse_documents',
  ];

  /// The copies of the files picked to send (the picker keeps them, and the
  /// lighter photos made of them), and the files opened more than
  /// [keepOpened] ago. Never fails: what can't be deleted now is tried at
  /// the next start.
  static Future<void> clean() async {
    try {
      await FilePicker.clearTemporaryFiles();
    } catch (e) {
      debugPrint('Clearing picked files: $e');
    }
    try {
      final temp = await getTemporaryDirectory();
      final photos = Directory('${temp.path}/$compressedPhotos');
      if (await photos.exists()) await photos.delete(recursive: true);
    } catch (e) {
      debugPrint('Clearing compressed photos: $e');
    }
    try {
      final temp = await getTemporaryDirectory();
      final before = DateTime.now().subtract(keepOpened);
      for (final name in _openedFolders) {
        final folder = Directory('${temp.path}/$name');
        if (!await folder.exists()) continue;
        await for (final entity in folder.list()) {
          if (entity is File &&
              (await entity.lastModified()).isBefore(before)) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Clearing opened files: $e');
    }
  }
}
