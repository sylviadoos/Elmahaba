import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/features/chat/presentation/chat_images_args.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_attachment_kind.dart';

/// A photo full screen, whole: pinched to zoom (up to 5×), double-tapped
/// to zoom in where tapped and back out, dragged around while zoomed in.
class ChatZoomableImage extends StatefulWidget {
  const ChatZoomableImage({
    super.key,
    required this.image,
    required this.onZoomChanged,
  });

  final ChatImageFile image;

  /// Zoomed in or back out: while zoomed in, dragging moves the photo
  /// instead of swiping to the next one.
  final ValueChanged<bool> onZoomChanged;

  @override
  State<ChatZoomableImage> createState() => _ChatZoomableImageState();
}

class _ChatZoomableImageState extends State<ChatZoomableImage>
    with SingleTickerProviderStateMixin {
  static const double _doubleTapScale = 2.5;

  final TransformationController _transform = TransformationController();
  late final AnimationController _zoom = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  )..addListener(_onZoomTick);
  Animation<Matrix4>? _zoomTo;
  Offset _doubleTapAt = Offset.zero;
  bool _zoomed = false;

  @override
  void dispose() {
    _zoom.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _onZoomTick() {
    final zoomTo = _zoomTo;
    if (zoomTo != null) _transform.value = zoomTo.value;
  }

  void _setZoomed(bool zoomed) {
    if (zoomed == _zoomed) return;
    _zoomed = zoomed;
    widget.onZoomChanged(zoomed);
  }

  void _onDoubleTap() {
    final zoomIn = !_zoomed;
    // Scaled about the point tapped, which stays under the finger.
    const scale = _doubleTapScale;
    final end = zoomIn
        ? (Matrix4.identity()
            ..setEntry(0, 0, scale)
            ..setEntry(1, 1, scale)
            ..setEntry(0, 3, -_doubleTapAt.dx * (scale - 1))
            ..setEntry(1, 3, -_doubleTapAt.dy * (scale - 1)))
        : Matrix4.identity();
    _zoomTo = Matrix4Tween(
      begin: _transform.value,
      end: end,
    ).animate(CurvedAnimation(parent: _zoom, curve: Curves.easeOut));
    _zoom.forward(from: 0);
    _setZoomed(zoomIn);
  }

  @override
  Widget build(BuildContext context) {
    // Sharp enough zoomed in, without decoding a camera's full size.
    final pixels =
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context) *
                2)
            .round();

    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapAt = details.localPosition,
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _transform,
        minScale: 1,
        maxScale: 5,
        onInteractionStart: (_) => _zoom.stop(),
        onInteractionEnd: (_) =>
            _setZoomed(_transform.value.getMaxScaleOnAxis() > 1.01),
        child: SizedBox.expand(
          child: Hero(
            tag: widget.image.attachment.heroTag,
            child: Image(
              image: ResizeImage.resizeIfNeeded(
                pixels,
                null,
                FileImage(File(widget.image.path)),
              ),
              fit: BoxFit.contain,
              gaplessPlayback: true,
              // Not a photo after all.
              errorBuilder: (_, _, _) => Center(
                child: AppSvgIcon(
                  AppIcons.alertCircle,
                  size: 40.r,
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
