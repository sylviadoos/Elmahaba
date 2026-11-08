import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/new_complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/picked_attachment.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/attachment_source_sheet.dart';

export 'package:al_mahhaba_school/features/complaints/presentation/extensions/picked_attachment.dart';

/// What the school takes: photo and document extensions (lower case), how
/// many files and how big each.
typedef AttachmentLimits = ({
  List<String> photoExtensions,
  List<String> documentExtensions,
  int maxFiles,
  int maxMegabytes,
});

extension AttachmentPicker on BuildContext {
  /// JPEG quality photos are saved at: an iPhone's HEIC or a Samsung's 15 MB
  /// photo comes out a JPEG the school takes, well under the size limit.
  static const int _photoQuality = 80;

  static const AttachmentLimits _complaintLimits = (
    photoExtensions: ComplaintAttachmentRules.photoExtensions,
    documentExtensions: ComplaintAttachmentRules.documentExtensions,
    maxFiles: ComplaintAttachmentRules.maxFiles,
    maxMegabytes: ComplaintAttachmentRules.maxMegabytes,
  );

  /// For a complaint, a reply or a chat message, [current] already picked.
  /// Returns every file picked, each checked against
  /// [ComplaintAttachmentRules]: one that breaks them comes back with its
  /// [AttachmentProblem], to show why it won't be sent. The good ones only
  /// as many as there's room for; says so when some don't fit.
  Future<List<PickedAttachment>> pickComplaintAttachments({
    required List<PickedAttachment> current,
  }) async {
    final files = await _pickFiles(_complaintLimits);
    var room = current.roomLeft;
    var bytesLeft = current.bytesLeft;
    var dropped = false;
    final picked = <PickedAttachment>[];
    for (final file in files) {
      final path = file.path;
      if (path == null) continue;
      final size = file.lengthSync() ?? await file.length() ?? 0;
      final checked = PickedAttachment(
        name: file.name,
        path: path,
        size: size,
        problem: await _problemOf(file.name, path, size, bytesLeft),
      );
      if (checked.isValid) {
        if (room == 0) {
          dropped = true;
          continue;
        }
        room--;
        bytesLeft -= size;
      }
      picked.add(checked);
    }
    if (dropped && mounted) {
      showSnackBar(
        l10n.attachmentsMaxReached(ComplaintAttachmentRules.maxFiles),
        isError: true,
      );
    }
    return picked;
  }

  /// Lets the parent pick photos (from the gallery) or documents (from the
  /// files), [picked] already being attached. Returns the ones [limits]
  /// allow, as many as there's room for, and says why any were left out.
  Future<List<PickedAttachment>> pickAttachments({
    required int picked,
    required AttachmentLimits limits,
  }) async {
    final files = await _pickFiles(limits);
    if (files.isEmpty) return const [];

    final extensions = [
      ...limits.photoExtensions,
      ...limits.documentExtensions,
    ];
    final maxBytes = limits.maxMegabytes * 1024 * 1024;
    final allowed = <PickedAttachment>[];
    for (final file in files) {
      final path = file.path;
      final size = file.lengthSync() ?? await file.length();
      if (path != null &&
          extensions.contains(file.extension?.toLowerCase()) &&
          size != null &&
          size <= maxBytes) {
        allowed.add(PickedAttachment(name: file.name, path: path, size: size));
      }
    }
    if (!mounted) return const [];

    final room = limits.maxFiles - picked;
    if (allowed.length > room) {
      showSnackBar(l10n.tooManyAttachments(limits.maxFiles), isError: true);
    } else if (allowed.length < files.length) {
      showSnackBar(
        l10n.attachmentNotAllowed(limits.typesLabel(this), limits.maxMegabytes),
        isError: true,
      );
    }
    return allowed.take(room).toList();
  }

  /// Photos or documents, as the parent chooses; none when they cancel or
  /// the phone can't open them (said in a snack bar).
  Future<List<PlatformFile>> _pickFiles(AttachmentLimits limits) async {
    final source = await AttachmentSourceSheet.show(this);
    if (source == null || !mounted) return const [];
    try {
      final files = switch (source) {
        AttachmentSource.photos => await FilePicker.pickFiles(
          type: FileType.image,
          compressionQuality: _photoQuality,
        ),
        AttachmentSource.documents => await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: limits.documentExtensions,
        ),
      };
      return mounted ? files : const [];
    } on Exception catch (e) {
      debugPrint('pickAttachments: $e');
      if (mounted) showSnackBar(l10n.couldNotOpenFiles, isError: true);
      return const [];
    }
  }

  /// What's wrong with the file [name] at [path] for a complaint, [bytesLeft]
  /// of the total still free; null when nothing is.
  static Future<AttachmentProblem?> _problemOf(
    String name,
    String path,
    int size,
    int bytesLeft,
  ) async {
    final extension = PickedAttachment(
      name: name,
      path: path,
      size: size,
    ).extension;
    if (!ComplaintAttachmentRules.extensions.contains(extension) ||
        !await _contentIs(extension, path)) {
      return AttachmentProblem.typeNotAllowed;
    }
    if (size > ComplaintAttachmentRules.maxBytes) {
      return AttachmentProblem.tooLarge;
    }
    if (size > bytesLeft) return AttachmentProblem.overTotal;
    return null;
  }

  /// The file at [path] starts as an [extension] file does, so it isn't
  /// another kind renamed (the school checks the same). True when it can't
  /// be read here: the school still checks it.
  static Future<bool> _contentIs(String extension, String path) async {
    final List<int> head;
    try {
      final file = await File(path).open();
      try {
        head = await file.read(1024);
      } finally {
        await file.close();
      }
    } on FileSystemException {
      return true;
    }
    bool startsWith(List<int> signature) =>
        head.length >= signature.length &&
        [
          for (var i = 0; i < signature.length; i++) head[i] == signature[i],
        ].every((same) => same);

    return switch (extension) {
      'jpg' || 'jpeg' => startsWith(const [0xFF, 0xD8, 0xFF]),
      'png' => startsWith(const [0x89, 0x50, 0x4E, 0x47]),
      // "%PDF", which may come a little after the start.
      'pdf' => String.fromCharCodes(head).contains('%PDF'),
      // An Office 97–2003 file, and a ZIP for the newer one.
      'doc' => startsWith(const [0xD0, 0xCF, 0x11, 0xE0]),
      'docx' => startsWith(const [0x50, 0x4B, 0x03, 0x04]),
      _ => false,
    };
  }
}

extension AttachmentLimitsLabel on AttachmentLimits {
  /// "JPG, PNG or PDF" ("jpeg" goes with "jpg").
  String typesLabel(BuildContext context) {
    final types = [
      for (final extension in [...photoExtensions, ...documentExtensions])
        if (extension != 'jpeg' || !photoExtensions.contains('jpg'))
          extension.toUpperCase(),
    ];
    if (types.length < 2) return types.join();
    final or = ' ${context.l10n.or} ';
    final comma = context.isRtl ? '، ' : ', ';
    return '${types.sublist(0, types.length - 1).join(comma)}$or${types.last}';
  }
}
