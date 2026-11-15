import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics_compat.dart'
    show RenderingStrategy;

/// SVG icon from `assets/icons/`, e.g. `AppSvgIcon(AppIcons.navHome)`.
///
/// Tinted with [color], or the surrounding [IconTheme] color like a normal
/// [Icon]. Set [matchTextDirection] for arrows so they flip in Arabic.
class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon(
    this.asset, {
    super.key,
    this.size = 24,
    this.color,
    this.matchTextDirection = false,
  });

  final String asset;
  final double size;
  final Color? color;
  final bool matchTextDirection;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? IconTheme.of(context).color;
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      matchTextDirection: matchTextDirection,
      // Drawn once to an image (shared by every icon of the same size) and
      // tinted as it's copied. Drawn as shapes, a tinted icon would be
      // painted off screen first each time (`saveLayer`): a few on every
      // chat message, each frame of a scroll.
      renderingStrategy: RenderingStrategy.raster,
      colorFilter: tint == null
          ? null
          : ColorFilter.mode(tint, BlendMode.srcIn),
    );
  }
}
