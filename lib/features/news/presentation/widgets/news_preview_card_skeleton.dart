import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/widgets/skeleton.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_card_frame.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_preview_card.dart';

/// Grey stand-in for a [NewsPreviewCard] while the news loads.
class NewsPreviewCardSkeleton extends StatelessWidget {
  const NewsPreviewCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: NewsPreviewCard.width.w,
      child: NewsCardFrame(
        radius: 18.r,
        child: SkeletonPulse(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: NewsPreviewCard.photoHeight.h,
                color: AppColors.surface,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 9.h,
                  children: [
                    SkeletonBar(width: 76.w, height: 10.h), // date
                    SkeletonBar(height: 12.h), // title
                    SkeletonBar(width: 150.w, height: 12.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
