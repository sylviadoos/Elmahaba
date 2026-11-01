import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/features/news/domain/entities/news_entity.dart';

/// Top of the article: date chip, title, and "Al Mahabbah Schools" byline.
class NewsArticleHeadline extends StatelessWidget {
  const NewsArticleHeadline({super.key, required this.news});

  final NewsEntity news;

  @override
  Widget build(BuildContext context) {
    final date = news.date;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16.h,
      children: [
        if (date != null) _DateChip(date),
        Text(
          news.title,
          // Read in the article's own language (English for now).
          textDirection: news.title.textDirection,
          style: context.textTheme.titleLarge?.copyWith(
            fontSize: 23.sp,
            height: 30 / 23,
            fontWeight: FontWeight.w800,
          ),
        ),
        const _Byline(),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip(this.date);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: const ShapeDecoration(
          color: AppColors.blush,
          shape: StadiumBorder(),
        ),
        child: Text(
          DateFormat.yMMMd(locale).format(date),
          style: context.textTheme.bodySmall?.copyWith(
            fontSize: 13.sp,
            height: 1.2,
            fontWeight: FontWeight.w600,
            color: AppColors.mahabbahRed,
          ),
        ),
      ),
    );
  }
}

class _Byline extends StatelessWidget {
  const _Byline();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return Row(
      spacing: 10.w,
      children: [
        Container(
          width: 36.r,
          height: 36.r,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.mahabbahRed,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            AppImages.logoMarkWhite,
            width: 22.r,
            height: 16.r,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.schoolName,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              l10n.schoolNews,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12.sp,
                color: AppColors.slate,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
