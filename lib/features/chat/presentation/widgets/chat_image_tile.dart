import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_attachment_kind.dart';

/// A photo sent in the chat, [width] × [height], cropped to fill it: a
/// spinner while it loads, "Try again" when it didn't, "Checking file…"
/// while the school can't hand it out. Light on a school card,
/// see-through on the parent's red bubble ([onRed]).
class ChatImageTile extends StatelessWidget {
  const ChatImageTile({
    super.key,
    required this.attachment,
    required this.image,
    required this.width,
    required this.height,
    this.onRed = false,
    this.onTap,
  });

  final ChatAttachmentEntity attachment;

  /// Where it's saved, loading, or why it didn't load; null before it's
  /// asked for.
  final BaseState<String>? image;
  final double width;
  final double height;
  final bool onRed;

  /// Opens it full screen once saved; loads it again after it failed.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.r);
    final background = onRed
        ? AppColors.white.withValues(alpha: 0.16)
        : AppColors.surface;
    final path = image?.state == StateType.success ? image?.data : null;

    final Widget tile;
    if (path != null) {
      // Decoded at the size it's drawn, not the camera's: light to keep
      // in memory and to scroll past. Painted with the box's corners: no
      // clip layer.
      final pixels = (width * MediaQuery.devicePixelRatioOf(context)).round();
      tile = Hero(
        tag: attachment.heroTag,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: radius,
            image: DecorationImage(
              image: ResizeImage.resizeIfNeeded(
                pixels,
                null,
                FileImage(File(path)),
              ),
              fit: BoxFit.cover,
              // A file that isn't a photo after all: the plain box, and
              // full screen says it can't be shown.
              onError: (_, _) {},
            ),
          ),
          child: SizedBox(width: width, height: height),
        ),
      );
    } else {
      tile = DecoratedBox(
        decoration: BoxDecoration(color: background, borderRadius: radius),
        child: SizedBox(
          width: width,
          height: height,
          child: Center(child: _placeholder(context)),
        ),
      );
    }

    return Semantics(
      image: true,
      button: onTap != null,
      label: attachment.fileName,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: tile,
      ),
    );
  }

  /// What shows until the photo does.
  Widget _placeholder(BuildContext context) {
    final foreground = onRed ? AppColors.white : AppColors.mahabbahRed;
    if (!attachment.isAvailable) {
      return _note(context, AppIcons.photo, context.l10n.checkingFile);
    }
    if (image?.state == StateType.error) {
      return _note(context, AppIcons.alertCircle, context.l10n.tryAgain);
    }
    return SizedBox.square(
      dimension: 22.r,
      child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
    );
  }

  Widget _note(BuildContext context, String icon, String text) => Padding(
    padding: EdgeInsets.all(8.r),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 4.h,
      children: [
        AppSvgIcon(
          icon,
          size: 22.r,
          color: onRed ? AppColors.white : AppColors.mahabbahRed,
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(
            fontSize: 11.sp,
            height: 15 / 11,
            fontWeight: FontWeight.w600,
            color: onRed ? AppColors.white : AppColors.slate,
          ),
        ),
      ],
    ),
  );
}
