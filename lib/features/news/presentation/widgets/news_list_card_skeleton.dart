import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/widgets/skeleton.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_card_frame.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_list_card.dart';

/// Grey stand-in for a [NewsListCard] while the news loads.
class NewsListCardSkeleton extends StatelessWidget {
  const NewsListCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return NewsCardFrame(
      radius: 20.r,
      child: SkeletonPulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: NewsListCard.photoHeight.h,
              color: AppColors.surface,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10.h,
                children: [
                  SkeletonBar(width: 84.w, height: 10.h), // date
                  SkeletonBar(height: 14.h), // title
                  SkeletonBar(width: 180.w, height: 14.h),
                  SizedBox(height: 2.h),
                  SkeletonBar(height: 10.h), // excerpt
                  SkeletonBar(width: 220.w, height: 10.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
