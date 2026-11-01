import 'package:flutter/material.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';

/// An icon centered in a colored rounded square (or circle) — the icon
/// tiles used across the designs. Defaults to red on blush.
class IconBox extends StatelessWidget {
  const IconBox(
    this.icon, {
    super.key,
    required this.size,
    required this.iconSize,
    this.radius = 0,
    this.background = AppColors.blush,
    this.color = AppColors.mahabbahRed,
    this.circle = false,
  });

  final String icon;
  final double size;
  final double iconSize;
  final double radius;
  final Color background;
  final Color color;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
      child: AppSvgIcon(icon, size: iconSize, color: color),
    );
  }
}
