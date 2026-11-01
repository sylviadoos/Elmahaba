import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/network/status_code.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/visitor_page.dart';
import 'package:al_mahhaba_school/features/news/domain/entities/news_entity.dart';
import 'package:al_mahhaba_school/features/news/presentation/view_model/news_details_event.dart';
import 'package:al_mahhaba_school/features/news/presentation/view_model/news_details_view_model.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_article_body.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_article_headline.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_article_hero.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_article_skeleton.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';

/// A full news article from the API: photo, date, title and text.
class NewsArticlePage extends StatelessWidget {
  const NewsArticlePage({super.key, required this.slug, this.preview});

  final String slug;

  /// The news as shown in the list, so its photo and title appear right
  /// away while the article loads.
  final NewsEntity? preview;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<NewsDetailsViewModel>()..doAction(GetNewsDetailsEvent(slug)),
      child: BlocBuilder<NewsDetailsViewModel, NewsDetailsState>(
        builder: (context, state) {
          final news = state.data ?? preview;

          return VisitorPage(
            header: NewsArticleHero(photoUrl: news?.thumbnailUrl),
            topPadding: 12,
            spacing: 16,
            children: state.when(
              initial: () => _loading(news),
              loading: () => _loading(news),
              error: (exception) => [
                StateMessage(
                  icon: AppIcons.info,
                  title: exception.localizedMessage(context),
                  // A deleted article won't come back on retry.
                  action: exception.statusCode == StatusCode.notFound
                      ? null
                      : AppButton(
                          label: context.l10n.tryAgain,
                          outlined: true,
                          expand: false,
                          onPressed: () => context
                              .read<NewsDetailsViewModel>()
                              .doAction(GetNewsDetailsEvent(slug)),
                        ),
                ),
              ],
              success: (details) => [
                NewsArticleHeadline(news: details),
                NewsArticleBody(details: details),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _loading(NewsEntity? news) => [
    if (news != null) NewsArticleHeadline(news: news),
    NewsArticleSkeleton(withHeadline: news == null),
  ];
}
