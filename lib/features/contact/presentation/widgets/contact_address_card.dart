import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/utils/external_links.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';

/// The school's address on a pink card, with an "Open in Google Maps"
/// button when there is a map link.
class ContactAddressCard extends StatelessWidget {
  const ContactAddressCard({super.key, required this.address, this.mapUrl});

  final String address;
  final String? mapUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final mapUrl = this.mapUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: ColoredBox(
        color: AppColors.blush,
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _CurvesPainter()),
            ),
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 14.h,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 14.w,
                    children: [
                      IconBox(
                        AppIcons.mapPin,
                        size: 48.r,
                        iconSize: 22.r,
                        radius: 16.r,
                        background: AppColors.mahabbahRed,
                        color: AppColors.white,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2.h,
                          children: [
                            Text(
                              l10n.ourSchool,
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mahabbahRed,
                              ),
                            ),
                            Text(
                              address,
                              style: textTheme.bodyLarge?.copyWith(
                                height: 22 / 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (mapUrl != null && mapUrl.isNotEmpty)
                    ElevatedButton(
                      onPressed: () => ExternalLinks.open(
                        context,
                        ExternalLinks.web(mapUrl),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(48.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        textStyle: textTheme.labelLarge?.copyWith(
                          fontSize: 15.sp,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8.w,
                        children: [
                          AppSvgIcon(AppIcons.navigate, size: 18.r),
                          Text(l10n.openInGoogleMaps),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The soft decorative road lines behind the address (design viewBox
/// 350 × 150, scaled to fit the card).
class _CurvesPainter extends CustomPainter {
  const _CurvesPainter();

  static const Size _viewBox = Size(350, 150);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(
      size.width / _viewBox.width,
      size.height / _viewBox.height,
    );
    canvas
      ..translate(
        (size.width - _viewBox.width * scale) / 2,
        (size.height - _viewBox.height * scale) / 2,
      )
      ..scale(scale);

    Paint stroke(double width) => Paint()
      ..color = AppColors.rose
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawPath(
        Path()
          ..moveTo(-10, 40)
          ..cubicTo(60, 60, 120, 20, 190, 50)
          ..cubicTo(260, 80, 320, 90, 370, 60),
        stroke(10),
      )
      ..drawPath(
        Path()
          ..moveTo(40, -10)
          ..cubicTo(60, 60, 30, 110, 70, 170),
        stroke(8),
      )
      ..drawPath(
        Path()
          ..moveTo(250, -10)
          ..cubicTo(240, 50, 280, 100, 260, 170),
        stroke(8),
      );
  }

  @override
  bool shouldRepaint(covariant _CurvesPainter oldDelegate) => false;
}
