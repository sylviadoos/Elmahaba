import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';

/// The save dialog in a widget test: what it was handed, and what came of
/// it.
class FakeFilePicker extends FilePickerPlatform {
  FakeFilePicker(this._outcome);

  final Future<Uri?> Function() _outcome;

  String? fileName;
  Uint8List? bytes;
  String? mimeType;

  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) {
    this.fileName = fileName;
    this.bytes = bytes;
    this.mimeType = mimeType;
    return _outcome();
  }
}

/// A [FakeFilePicker] instead of the real dialog until the test ends; it
/// saves, unless [outcome] says otherwise.
FakeFilePicker useFakeFilePicker({Future<Uri?> Function()? outcome}) {
  final real = FilePickerPlatform.instance;
  addTearDown(() => FilePickerPlatform.instance = real);
  final fake = FakeFilePicker(
    outcome ?? () async => Uri.parse('content://downloads/certificate'),
  );
  FilePickerPlatform.instance = fake;
  return fake;
}
