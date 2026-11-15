import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/chat_image_source.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_image_link.dart';

/// An item's photos (a chat item, a homework), [width] wide, loaded from
/// the page's [source]: one alone fills it (4:3), more sit two to a row
/// as squares.
class ChatImageGrid extends StatelessWidget {
  const ChatImageGrid({
    super.key,
    required this.source,
    required this.images,
    required this.width,
    this.onRed = false,
  });

  final ChatImageSource source;
  final List<ChatAttachmentEntity> images;
  final double width;

  /// On the parent's red bubble.
  final bool onRed;

  @override
  Widget build(BuildContext context) {
    if (images.length == 1) {
      return ChatImageLink(
        source: source,
        images: images,
        index: 0,
        width: width,
        height: width * 3 / 4,
        onRed: onRed,
      );
    }

    final gap = 4.r;
    final side = (width - gap) / 2;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: gap,
      children: [
        for (var row = 0; row < images.length; row += 2)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: gap,
            children: [
              for (var i = row; i < math.min(row + 2, images.length); i++)
                ChatImageLink(
                  source: source,
                  images: images,
                  index: i,
                  width: side,
                  height: side,
                  onRed: onRed,
                ),
            ],
          ),
      ],
    );
  }
}
