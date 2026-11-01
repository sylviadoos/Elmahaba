import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/core/widgets/skeleton.dart';

/// Grey lines standing in for the article while it loads. [withHeadline]
/// adds the date and title too, when they aren't known yet.
class NewsArticleSkeleton extends StatelessWidget {
  const NewsArticleSkeleton({super.key, this.withHeadline = false});

  final bool withHeadline;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.h,
        children: [
          if (withHeadline) ...[
            SkeletonBar(width: 96.w, height: 24.h), // date chip
            SkeletonBar(height: 22.h), // title
            SkeletonBar(width: 220.w, height: 22.h),
            SizedBox(height: 12.h),
          ],
          for (var paragraph = 0; paragraph < 2; paragraph++) ...[
            SkeletonBar(height: 12.h),
            SkeletonBar(height: 12.h),
            SkeletonBar(height: 12.h),
            SkeletonBar(width: 200.w, height: 12.h),
            SizedBox(height: 8.h),
          ],
        ],
      ),
    );
  }
}
