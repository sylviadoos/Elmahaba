import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_photo.dart';

/// The article's photo across the top, with the wave and a back button.
class NewsArticleHero extends StatelessWidget {
  const NewsArticleHero({super.key, this.photoUrl});

  /// Null shows the placeholder (no photo, or not loaded yet).
  final String? photoUrl;

  static const double height = 250;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: height.h,
      child: Stack(
        children: [
          Positioned.fill(child: NewsPhoto(photoUrl, height: height.h)),
          Positioned(
            left: 0,
            right: 0,
            bottom: -1,
            child: SvgPicture.asset(
              AppImages.headerWave,
              height: 26.r,
              fit: BoxFit.fill,
            ),
          ),
          PositionedDirectional(
            start: 20.w,
            top: topInset + 8.h,
            child: const AppBackButton(style: AppBackButtonStyle.onPhoto),
          ),
        ],
      ),
    );
  }
}
