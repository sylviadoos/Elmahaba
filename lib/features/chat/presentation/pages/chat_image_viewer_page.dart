import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/features/chat/presentation/chat_images_args.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_file_opener.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_viewer_bar.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_zoomable_image.dart';

/// A chat item's photos full screen, on dark: the one tapped first,
/// swiping to the others, each zoomable. The bar closes it or opens the
/// photo in another app (to save or share it).
class ChatImageViewerPage extends StatefulWidget {
  const ChatImageViewerPage({super.key, required this.args});

  final ChatImagesArgs args;

  @override
  State<ChatImageViewerPage> createState() => _ChatImageViewerPageState();
}

class _ChatImageViewerPageState extends State<ChatImageViewerPage> {
  late int _index = widget.args.initialIndex.clamp(
    0,
    widget.args.images.length - 1,
  );
  late final PageController _pages = PageController(initialPage: _index);

  /// The photo shown is zoomed in: dragging moves it, not to the next.
  bool _zoomed = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _openElsewhere() =>
      context.openOutside(widget.args.images[_index].path);

  @override
  Widget build(BuildContext context) {
    final images = widget.args.images;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pages,
              physics: _zoomed ? const NeverScrollableScrollPhysics() : null,
              itemCount: images.length,
              onPageChanged: (index) => setState(() {
                _index = index;
                _zoomed = false;
              }),
              itemBuilder: (_, index) => ChatZoomableImage(
                image: images[index],
                onZoomChanged: (zoomed) => setState(() => _zoomed = zoomed),
              ),
            ),
            PositionedDirectional(
              top: 0,
              start: 0,
              end: 0,
              child: ChatViewerBar(
                title: images[_index].attachment.fileName,
                position: images.length > 1
                    ? '${_index + 1} / ${images.length}'
                    : null,
                onClose: context.pop,
                onOpenElsewhere: _openElsewhere,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
