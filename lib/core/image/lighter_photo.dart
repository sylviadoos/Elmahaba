import 'dart:io';

import 'package:al_mahhaba_school/core/image/photo_compressor.dart';

/// A file picked to send: its name, where it is, its size in bytes.
typedef PickedFile = ({String name, String path, int size});

extension LighterPhoto on PhotoCompressor {
  /// The photos made lighter, by their extension (lower case).
  static const Set<String> photoExtensions = {
    'jpg',
    'jpeg',
    'png',
    'heic',
    'heif',
    'webp',
  };

  /// The ones sent as they are when making them lighter doesn't.
  static const Set<String> _sentAsIs = {'jpg', 'jpeg', 'png'};

  /// [file] as it's to be sent: a photo made lighter, a JPEG named ".jpg".
  /// As it was when it's no photo, can't be read as one (the checks then
  /// say why it won't go), or isn't any lighter so (a small PNG, say); a
  /// HEIC or WEBP is always made a JPEG, the school doesn't take them.
  Future<PickedFile> lighter(PickedFile file) async {
    final extension = _extensionOf(file.name);
    if (!photoExtensions.contains(extension)) return file;
    final compressed = await compress(file.path);
    if (compressed == null) return file;
    if (_sentAsIs.contains(extension) && compressed.size >= file.size) {
      try {
        await File(compressed.path).delete();
      } on FileSystemException {
        // Cleared with the temporary files anyway.
      }
      return file;
    }
    return (
      name: '${_withoutExtension(file.name)}.jpg',
      path: compressed.path,
      size: compressed.size,
    );
  }

  static String _extensionOf(String name) {
    final dot = name.lastIndexOf('.');
    return dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  }

  static String _withoutExtension(String name) {
    final dot = name.lastIndexOf('.');
    return dot <= 0 ? name : name.substring(0, dot);
  }
}
