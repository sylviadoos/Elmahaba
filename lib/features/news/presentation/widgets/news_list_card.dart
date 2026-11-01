import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:al_mahhaba_school/features/news/domain/entities/news_entity.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_card_frame.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_meta_and_title.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_photo.dart';

/// Full-width news card for the News page: the photo (or a placeholder for
/// news without one), then date, title and excerpt.
class NewsListCard extends StatelessWidget {
  const NewsListCard({super.key, required this.news, this.onTap});

  final NewsEntity news;
  final VoidCallback? onTap;

  /// Photo height in design pixels; also used by the loading skeleton.
  static const double photoHeight = 186;

  @override
  Widget build(BuildContext context) {
    final date = news.date;
    final locale = Localizations.localeOf(context).toString();

    return NewsCardFrame(
      radius: 20.r,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NewsPhoto(news.thumbnailUrl, height: photoHeight.h),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
            child: NewsMetaAndTitle(
              // "Nov 17, 2025" / "١٧ نوفمبر ٢٠٢٥"
              meta: date == null ? null : DateFormat.yMMMd(locale).format(date),
              title: news.title,
              excerpt: news.excerpt,
              titleSize: 16,
              titleHeight: 21,
            ),
          ),
        ],
      ),
    );
  }
}
