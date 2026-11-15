import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// White card of a school item, with a colored stripe along its start
/// edge: dark maroon for general items, red for private ones.
class ChatAccentCard extends StatelessWidget {
  const ChatAccentCard({
    super.key,
    required this.isGeneral,
    required this.child,
  });

  final bool isGeneral;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isRtl = context.isRtl;

    // Flutter can't give a box a thicker start border with rounded corners,
    // so the card is painted in one go: no clip, no layers over it. No
    // shadow: the border sets it apart, and the chat stays light.
    return CustomPaint(
      painter: _AccentCardPainter(
        radius: BorderRadiusDirectional.only(
          topStart: Radius.circular(4.r),
          topEnd: Radius.circular(18.r),
          bottomStart: Radius.circular(18.r),
          bottomEnd: Radius.circular(18.r),
        ).resolve(isRtl ? TextDirection.rtl : TextDirection.ltr),
        stripe: isGeneral ? AppColors.maroon : AppColors.actionRed,
        stripeWidth: 5.w,
        stripeOnRight: isRtl,
      ),
      child: Padding(
        // 5 px stripe + 16 px from the start edge, 15 px elsewhere
        // (padding sits inside the 1 px border).
        padding: EdgeInsetsDirectional.fromSTEB(20.w, 14.r, 14.r, 14.r),
        child: child,
      ),
    );
  }
}

/// The card: white, its 1 px border, then the stripe over the border's
/// start side, kept inside the rounded corners.
class _AccentCardPainter extends CustomPainter {
  const _AccentCardPainter({
    required this.radius,
    required this.stripe,
    required this.stripeWidth,
    required this.stripeOnRight,
  });

  final BorderRadius radius;
  final Color stripe;
  final double stripeWidth;
  final bool stripeOnRight;

  @override
  void paint(Canvas canvas, Size size) {
    final card = radius.toRRect(Offset.zero & size);
    canvas
      ..drawRRect(card, Paint()..color = AppColors.white)
      ..drawRRect(
        card.deflate(0.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = AppColors.line,
      )
      ..save()
      ..clipRRect(card)
      ..drawRect(
        Rect.fromLTWH(
          stripeOnRight ? size.width - stripeWidth : 0,
          0,
          stripeWidth,
          size.height,
        ),
        Paint()..color = stripe,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_AccentCardPainter oldDelegate) =>
      radius != oldDelegate.radius ||
      stripe != oldDelegate.stripe ||
      stripeWidth != oldDelegate.stripeWidth ||
      stripeOnRight != oldDelegate.stripeOnRight;
}
