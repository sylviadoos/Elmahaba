import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/widgets/skeleton.dart';

/// Grey stand-in for the address card and contact tiles while they load.
class ContactSkeleton extends StatelessWidget {
  const ContactSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget block(double height, double radius) => Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    return SkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24.h,
        children: [
          block(156.h, 24.r), // address card
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10.h,
            children: [
              SkeletonBar(width: 120.w, height: 16.h), // "Call or email"
              for (var tile = 0; tile < 3; tile++)
                SizedBox(width: double.infinity, child: block(66.h, 18.r)),
            ],
          ),
        ],
      ),
    );
  }
}
