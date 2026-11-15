import 'package:flutter/widgets.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/chat_image_source.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_images_viewer.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_image_tile.dart';

/// One of an item's photos, from the page's [source]: loaded as it comes
/// on screen, opened full screen by a tap (swiping through the item's
/// other photos), loaded again by a tap when it failed. Only this rebuilds
/// as it loads, not the page around it.
class ChatImageLink extends StatefulWidget {
  const ChatImageLink({
    super.key,
    required this.source,
    required this.images,
    required this.index,
    required this.width,
    required this.height,
    this.onRed = false,
  });

  final ChatImageSource source;

  /// The item's photos; this is the one at [index].
  final List<ChatAttachmentEntity> images;
  final int index;
  final double width;
  final double height;
  final bool onRed;

  @override
  State<ChatImageLink> createState() => _ChatImageLinkState();
}

class _ChatImageLinkState extends State<ChatImageLink> {
  ChatAttachmentEntity get _attachment => widget.images[widget.index];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ChatImageLink oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Loaded again: the school may hand it out now.
    if (oldWidget.images[oldWidget.index] != _attachment) _load();
  }

  void _load() => widget.source.load(context, _attachment);

  void _open() => context.openChatImages(
    widget.images,
    saved: widget.source.saved(context),
    tapped: _attachment,
  );

  @override
  Widget build(BuildContext context) {
    final image = widget.source.watch(context, _attachment.id);

    return ChatImageTile(
      attachment: _attachment,
      image: image,
      width: widget.width,
      height: widget.height,
      onRed: widget.onRed,
      onTap: switch (image?.state) {
        StateType.success => _open,
        StateType.error => _load,
        _ => null,
      },
    );
  }
}
