import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:al_mahhaba_school/features/news/domain/entities/news_entity.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_card_frame.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_meta_and_title.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_photo.dart';

/// Small news card for the horizontal "Latest news" row on Explore.
class NewsPreviewCard extends StatelessWidget {
  const NewsPreviewCard({super.key, required this.news, this.onTap});

  final NewsEntity news;
  final VoidCallback? onTap;

  /// Card width and photo height in design pixels; also used by the
  /// loading skeleton.
  static const double width = 250;
  static const double photoHeight = 133;

  @override
  Widget build(BuildContext context) {
    final date = news.date;
    final locale = Localizations.localeOf(context).toString();

    return SizedBox(
      width: width.w,
      child: NewsCardFrame(
        radius: 18.r,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NewsPhoto(news.thumbnailUrl, height: photoHeight.h),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
              child: NewsMetaAndTitle(
                // "Nov 17, 2025" / "١٧ نوفمبر ٢٠٢٥"
                meta: date == null
                    ? null
                    : DateFormat.yMMMd(locale).format(date),
                title: news.title,
                titleSize: 14,
                titleHeight: 19,
                titleMaxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
