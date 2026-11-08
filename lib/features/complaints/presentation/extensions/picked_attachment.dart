import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/new_complaint_entity.dart';

/// Why a file picked can't be sent.
enum AttachmentProblem {
  /// Not a JPG, PNG, PDF, DOC or DOCX, by its name or by what's in it.
  typeNotAllowed,

  /// Bigger than one file may be.
  tooLarge,

  /// Would take the files over what they may add up to.
  overTotal,

  /// The school didn't accept it (MSG-18).
  rejected,
}

/// A file picked to send: its name, where it is, its size in bytes, and why
/// it can't be sent ([problem]), if it can't.
class PickedAttachment extends Equatable {
  const PickedAttachment({
    required this.name,
    required this.path,
    required this.size,
    this.problem,
  });

  /// e.g. "bus-photo.jpg".
  final String name;
  final String path;
  final int size;
  final AttachmentProblem? problem;

  bool get isValid => problem == null;

  /// Lower case, e.g. "pdf"; empty when the name has none.
  String get extension {
    final dot = name.lastIndexOf('.');
    return dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  }

  PickedAttachment withProblem(AttachmentProblem problem) =>
      PickedAttachment(name: name, path: path, size: size, problem: problem);

  @override
  List<Object?> get props => [name, path, size, problem];
}

/// The files picked for a complaint, a reply or a chat message, against
/// [ComplaintAttachmentRules].
extension PickedAttachments on List<PickedAttachment> {
  /// The ones that can be sent.
  List<PickedAttachment> get valid => [
    for (final file in this)
      if (file.isValid) file,
  ];

  int get validBytes => valid.fold(0, (sum, file) => sum + file.size);

  /// Files were picked, but none of them can be sent.
  bool get allInvalid => isNotEmpty && every((file) => !file.isValid);

  /// How many more can be added.
  int get roomLeft =>
      math.max(0, ComplaintAttachmentRules.maxFiles - valid.length);

  /// What's left of the total they may add up to, in bytes.
  int get bytesLeft =>
      math.max(0, ComplaintAttachmentRules.maxTotalBytes - validBytes);

  /// Another file fits, by count and by total size.
  bool get canAddMore => roomLeft > 0 && bytesLeft > 0;

  /// These, the one named [fileName] marked as refused by the school.
  List<PickedAttachment> rejecting(String? fileName) => [
    for (final file in this)
      file.isValid && file.name == fileName
          ? file.withProblem(AttachmentProblem.rejected)
          : file,
  ];

  /// How much of each file sent has gone (0 to 1), [upload] being the
  /// request's: the text goes first, then the files one after another, in
  /// order. (Each file's few header bytes count as the text's.)
  Map<PickedAttachment, double> uploadProgress(UploadProgress upload) {
    final files = valid;
    var start =
        upload.total - files.fold<int>(0, (sum, file) => sum + file.size);
    final progress = <PickedAttachment, double>{};
    for (final file in files) {
      progress[file] = file.size == 0
          ? (upload.sent >= start ? 1 : 0)
          : ((upload.sent - start) / file.size).clamp(0.0, 1.0);
      start += file.size;
    }
    return progress;
  }
}
