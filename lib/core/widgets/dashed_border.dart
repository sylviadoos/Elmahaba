import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';

/// Full-width horizontal dashed line, e.g. between chat messages.
class DashedLine extends StatelessWidget {
  const DashedLine({
    super.key,
    this.color = AppColors.separator,
    this.thickness = 1.5,
  });

  final Color color;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: thickness,
      child: CustomPaint(
        painter: _DashedLinePainter(color: color, thickness: thickness),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color, required this.thickness});

  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness;
    final y = size.height / 2;
    for (
      var x = 0.0;
      x < size.width;
      x += _DashedBorderPainter._dash + _DashedBorderPainter._gap
    ) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + _DashedBorderPainter._dash).clamp(0, size.width), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.thickness != thickness;
}

/// Draws a dashed rounded border around [child] (Flutter has no built-in
/// dashed border).
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    super.key,
    required this.child,
    this.color = AppColors.actionRed,
    this.radius = 0,
    this.strokeWidth = 1.5,
  });

  final Widget child;
  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        radius: radius,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  static const double _dash = 5;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final border = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(strokeWidth / 2),
          Radius.circular(radius),
        ),
      );

    for (final PathMetric metric in border.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += _dash + _gap) {
        canvas.drawPath(metric.extractPath(start, start + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth;
}
