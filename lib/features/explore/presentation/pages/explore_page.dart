import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/equal_height_grid.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';
import 'package:al_mahhaba_school/features/news/presentation/view_model/news_event.dart';
import 'package:al_mahhaba_school/features/news/presentation/view_model/news_view_model.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_preview_card.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_preview_card_skeleton.dart';
import 'package:al_mahhaba_school/core/widgets/section_title.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/core/widgets/visitor_page.dart';

/// Visitor home: what the school offers, latest news and ways to get in
/// touch, with links to About us, News and Contact.
class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const VisitorPage(
      header: _ExploreHeader(),
      children: [
        _QuickLinks(),
        _LanguageSchoolCard(),
        _WhyChooseUs(),
        _LatestNews(),
        _JoinCard(),
      ],
    );
  }
}

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return RedHeader(
      bottomPadding: 48,
      watermarkTop: 70,
      watermarkSize: const Size(250, 178),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 22.h,
        children: [
          Row(
            spacing: 10.w,
            children: [
              SvgPicture.asset(
                AppImages.logoMarkWhite,
                width: 42.r,
                height: 30.r,
              ),
              Text(
                l10n.schoolNameTwoLines,
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 14.sp,
                  height: 16 / 14,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4.h,
            children: [
              Text(
                l10n.welcomeTo,
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 15.sp,
                  height: 1.3,
                  color: AppColors.white.withValues(alpha: 0.85),
                ),
              ),
              Text(
                l10n.schoolName,
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.white,
                  letterSpacing: 0,
                ),
              ),
              Text(
                l10n.schoolTagline,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return EqualHeightGrid(
      columns: 3,
      spacing: 10.w,
      children: [
        _QuickLink(
          icon: AppIcons.info,
          label: l10n.aboutUs,
          route: AppRoutes.about,
        ),
        _QuickLink(
          icon: AppIcons.news,
          label: l10n.news,
          route: AppRoutes.news,
        ),
        _QuickLink(
          icon: AppIcons.phone,
          label: l10n.contact,
          route: AppRoutes.contact,
        ),
      ],
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.label,
    required this.route,
  });

  final String icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(route),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 14.h),
          child: Column(
            spacing: 8.h,
            children: [
              IconBox(icon, size: 44.r, iconSize: 20.r, radius: 14.r),
              Text(
                label,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Language school — Curricula taught in English" card with a student photo.
class _LanguageSchoolCard extends StatelessWidget {
  const _LanguageSchoolCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: SizedBox(
        height: 230.h,
        child: ColoredBox(
          color: AppColors.blush,
          child: Stack(
            children: [
              PositionedDirectional(
                end: -30.w,
                bottom: -60.h,
                child: _Circle(
                  size: 240.r,
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
              ),
              PositionedDirectional(
                end: -14.w,
                bottom: -40.h,
                child: Image.asset(
                  AppImages.studentTeen,
                  width: 206.r,
                  height: 271.r,
                ),
              ),
              PositionedDirectional(
                start: 20.w,
                top: 22.h,
                bottom: 22.h,
                width: 160.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10.h,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: const ShapeDecoration(
                        color: AppColors.white,
                        shape: StadiumBorder(),
                      ),
                      child: Text(
                        l10n.languageSchool,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mahabbahRed,
                        ),
                      ),
                    ),
                    Text(
                      l10n.curriculaInEnglish,
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 20.sp,
                        height: 25 / 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => context.push(AppRoutes.about),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(0, 44.h),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        textStyle: textTheme.labelLarge?.copyWith(
                          fontSize: 14.sp,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 6.w,
                        children: [
                          Text(l10n.aboutUs),
                          AppSvgIcon(
                            AppIcons.arrowRight,
                            size: 16.r,
                            matchTextDirection: true,
                          ),
                        ],
                      ),
                    ),
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

class _WhyChooseUs extends StatelessWidget {
  const _WhyChooseUs();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12.h,
      children: [
        SectionTitle(l10n.whyFamiliesChooseUs),
        EqualHeightGrid(
          columns: 2,
          spacing: 12.w,
          children: [
            _FeatureTile(
              icon: AppIcons.book,
              title: l10n.featureCurriculaTitle,
              body: l10n.featureCurriculaBody,
            ),
            _FeatureTile(
              icon: AppIcons.bus,
              title: l10n.featureBusesTitle,
              body: l10n.featureBusesBody,
            ),
            _FeatureTile(
              icon: AppIcons.shieldCheck,
              title: l10n.featureSafeTitle,
              body: l10n.featureSafeBody,
            ),
            _FeatureTile(
              icon: AppIcons.heart,
              title: l10n.featureValuesTitle,
              body: l10n.featureValuesBody,
            ),
          ],
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final String icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10.h,
        children: [
          IconBox(icon, size: 38.r, iconSize: 19.r, radius: 12.r),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2.h,
            children: [
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                body,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  height: 1.3,
                  color: AppColors.slate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The two newest articles from the news API, with "See all".
class _LatestNews extends StatelessWidget {
  const _LatestNews();

  static const int _count = 2;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider(
      create: (_) => getIt<NewsViewModel>()..doAction(const GetNewsEvent()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12.h,
        children: [
          SectionTitle(
            l10n.latestNews,
            trailing: TextButton(
              onPressed: () => context.push(AppRoutes.news),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.actionRed,
                minimumSize: Size.zero,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: context.textTheme.labelLarge?.copyWith(
                  fontSize: 14.sp,
                ),
              ),
              child: Text(l10n.seeAll),
            ),
          ),
          BlocBuilder<NewsViewModel, NewsState>(
            builder: (context, state) => state.when(
              initial: _skeletons,
              loading: _skeletons,
              error: (exception) => _NewsRowMessage(
                message: exception.localizedMessage(context),
                onRetry: () => context.read<NewsViewModel>().doAction(
                  const GetNewsEvent(),
                ),
              ),
              success: (news) => news.isEmpty
                  ? _NewsRowMessage(message: l10n.noNewsYet)
                  : _CardsRow(
                      children: [
                        for (final item in news.take(_count))
                          NewsPreviewCard(
                            news: item,
                            onTap: () => context.push(
                              AppRoutes.newsArticleOf(item.slug),
                              extra: item,
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _skeletons() => const _CardsRow(
    children: [NewsPreviewCardSkeleton(), NewsPreviewCardSkeleton()],
  );
}

/// Cards side by side, all as tall as the tallest. Scrolls edge to edge:
/// cards slide under the page padding.
class _CardsRow extends StatelessWidget {
  const _CardsRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12.w,
          children: children,
        ),
      ),
    );
  }
}

/// One-line note in place of the cards (no news, or they failed to load),
/// with "Try again" when [onRetry] is set.
class _NewsRowMessage extends StatelessWidget {
  const _NewsRowMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final onRetry = this.onRetry;

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 6.h, 6.w, 6.h),
      constraints: BoxConstraints(minHeight: 56.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: AppColors.actionRed),
              child: Text(context.l10n.tryAgain),
            ),
        ],
      ),
    );
  }
}

/// "Interested in joining?" card with a link to Contact.
class _JoinCard extends StatelessWidget {
  const _JoinCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: ColoredBox(
        color: AppColors.maroon,
        child: Stack(
          children: [
            PositionedDirectional(
              end: -40.w,
              bottom: -70.h,
              child: _Circle(
                size: 210.r,
                color: AppColors.white.withValues(alpha: 0.08),
              ),
            ),
            PositionedDirectional(
              end: -22.w,
              bottom: -8.h,
              child: Image.asset(
                AppImages.studentGirlFlex,
                width: 168.r,
                height: 156.r,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10.h,
                children: [
                  SizedBox(
                    width: 180.w,
                    child: Text(
                      l10n.interestedInJoining,
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 19.sp,
                        height: 24 / 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 180.w,
                    child: Text(
                      l10n.admissionTeamWillAnswer,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        height: 21 / 14,
                        color: AppColors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context.push(AppRoutes.contact),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.mahabbahRed,
                      minimumSize: Size(0, 46.h),
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      textStyle: textTheme.labelLarge?.copyWith(
                        fontSize: 15.sp,
                      ),
                    ),
                    child: Text(l10n.contactAdmission),
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

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
