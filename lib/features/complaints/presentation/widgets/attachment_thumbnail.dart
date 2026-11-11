import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/picked_attachment.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/attachment_type_badge.dart';

/// A photo picked to send, small (the size of an [AttachmentTypeBadge]),
/// cropped to fill its square; [onTap] shows it bigger. Its kind instead
/// when it can't be drawn.
class AttachmentThumbnail extends StatelessWidget {
  const AttachmentThumbnail(this.file, {super.key, this.onTap});

  final PickedAttachment file;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final side = 40.r;
    final radius = BorderRadius.circular(10.r);
    // Decoded at the size it's drawn, not the camera's.
    final pixels = (side * MediaQuery.devicePixelRatioOf(context)).round();

    return Semantics(
      image: true,
      button: onTap != null,
      label: file.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: side,
          // A few picked files at most, outside any list: the clip costs
          // nothing worth saving here.
          child: ClipRRect(
            borderRadius: radius,
            child: Image(
              image: ResizeImage.resizeIfNeeded(
                pixels,
                null,
                FileImage(File(file.path)),
              ),
              fit: BoxFit.cover,
              gaplessPlayback: true,
              // A grey square until it's drawn.
              frameBuilder: (_, child, frame, wasSynchronouslyLoaded) =>
                  frame == null && !wasSynchronouslyLoaded
                  ? const ColoredBox(color: AppColors.surface)
                  : child,
              errorBuilder: (_, _, _) => AttachmentTypeBadge(file.extension),
            ),
          ),
        ),
      ),
    );
  }
}
