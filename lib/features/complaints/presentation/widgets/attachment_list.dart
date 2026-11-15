import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/picked_attachment.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/attachment_row.dart';

/// The [files] picked, one [AttachmentRow] each. While they're sent
/// ([upload]), each shows how far it got, and none can be taken off.
class AttachmentList extends StatelessWidget {
  const AttachmentList({
    super.key,
    required this.files,
    this.upload,
    required this.onRemove,
    this.onPreview,
  });

  final List<PickedAttachment> files;
  final UploadProgress? upload;

  /// Gets the index of the file to take off; null while none can be.
  final ValueChanged<int>? onRemove;

  /// Gets the index of a photo tapped, to show it bigger; null where that
  /// isn't offered.
  final ValueChanged<int>? onPreview;

  @override
  Widget build(BuildContext context) {
    final upload = this.upload;
    final progress = upload == null ? null : files.uploadProgress(upload);
    final bytesLeft = files.bytesLeft;
    final onRemove = upload == null ? this.onRemove : null;
    final onPreview = this.onPreview;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8.h,
      children: [
        for (final (index, file) in files.indexed)
          AttachmentRow(
            file: file,
            bytesLeft: bytesLeft,
            progress: progress?[file],
            onRemove: onRemove == null ? null : () => onRemove(index),
            onPreview: onPreview == null ? null : () => onPreview(index),
          ),
      ],
    );
  }
}
