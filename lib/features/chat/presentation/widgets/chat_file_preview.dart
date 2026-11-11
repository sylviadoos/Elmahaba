import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/chat_image_source.dart';

/// The top of a PDF's first page, over its file card, from the page's
/// [source]: loaded as it comes on screen, a spinner meanwhile. Nothing
/// while the school can't hand it out or when it can't be drawn: the card
/// under it still opens the file.
class ChatFilePreview extends StatefulWidget {
  const ChatFilePreview({
    super.key,
    required this.source,
    required this.attachment,
    this.onRed = false,
  });

  final ChatImageSource source;
  final ChatAttachmentEntity attachment;

  /// On the parent's red bubble.
  final bool onRed;

  @override
  State<ChatFilePreview> createState() => _ChatFilePreviewState();
}

class _ChatFilePreviewState extends State<ChatFilePreview> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ChatFilePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Loaded again: the school may hand it out now.
    if (oldWidget.attachment != widget.attachment) _load();
  }

  void _load() => widget.source.load(context, widget.attachment);

  @override
  Widget build(BuildContext context) {
    final image = widget.source.watch(context, widget.attachment.id);
    if (!widget.attachment.isAvailable) return const SizedBox.shrink();
    // As wide as the card (at least this, in the parent's bubble).
    final width = 220.w;
    final height = 150.h;

    switch (image) {
      case BaseState(state: StateType.success, data: final String path):
        // Decoded about as wide as a card is drawn, not the page's size.
        final pixels = (360.w * MediaQuery.devicePixelRatioOf(context)).round();
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            image: DecorationImage(
              image: ResizeImage.resizeIfNeeded(
                pixels,
                null,
                FileImage(File(path)),
              ),
              fit: BoxFit.cover,
              // The page's top: its title.
              alignment: Alignment.topCenter,
              onError: (_, _) {},
            ),
          ),
          child: SizedBox(width: width, height: height),
        );
      case null || BaseState(state: StateType.loading):
        return SizedBox(
          width: width,
          height: height,
          child: Center(
            child: SizedBox.square(
              dimension: 22.r,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: widget.onRed ? AppColors.white : AppColors.mahabbahRed,
              ),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
