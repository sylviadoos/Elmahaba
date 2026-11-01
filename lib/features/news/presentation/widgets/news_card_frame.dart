import 'package:flutter/material.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';

/// White card with a light border, rounded clipping and a tap ripple.
class NewsCardFrame extends StatelessWidget {
  const NewsCardFrame({
    super.key,
    required this.radius,
    required this.child,
    this.onTap,
  });

  final double radius;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(onTap: onTap, child: child),
    );
  }
}
