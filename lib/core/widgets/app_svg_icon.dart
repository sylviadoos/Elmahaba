import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      colorFilter: tint == null
          ? null
          : ColorFilter.mode(tint, BlendMode.srcIn),
    );
  }
}
