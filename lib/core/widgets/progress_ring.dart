import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';

/// Donut filled to [value] (0–1) in red over light rose, from the top,
/// with [child] in its white middle. Sizes are design pixels.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.size,
    required this.holeSize,
    this.child,
  });

  final double value;
  final double size;
  final double holeSize;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size.r,
      child: CustomPaint(
        painter: _RingPainter(value),
        child: Center(
          child: Container(
            width: holeSize.r,
            height: holeSize.r,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas
      ..drawOval(rect, Paint()..color = AppColors.rose)
      ..drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * value.clamp(0, 1),
        true,
        Paint()..color = AppColors.actionRed,
      );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value;
}
