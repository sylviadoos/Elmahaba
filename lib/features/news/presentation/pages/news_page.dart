import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/visitor_header.dart';
import 'package:al_mahhaba_school/core/widgets/visitor_page.dart';
import 'package:al_mahhaba_school/features/news/presentation/view_model/news_event.dart';
import 'package:al_mahhaba_school/features/news/presentation/view_model/news_view_model.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_list_card.dart';
import 'package:al_mahhaba_school/features/news/presentation/widgets/news_list_card_skeleton.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';

/// School news from the API.
class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider(
      create: (_) => getIt<NewsViewModel>()..doAction(const GetNewsEvent()),
      child: VisitorPage(
        header: VisitorHeader(title: l10n.news, subtitle: l10n.newsSubtitle),
        children: const [_NewsBody()],
      ),
    );
  }
}

class _NewsBody extends StatelessWidget {
  const _NewsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsViewModel, NewsState>(
      builder: (context, state) {
        final l10n = context.l10n;
        final children = state.when(
          initial: _skeletons,
          loading: _skeletons,
          error: (exception) => [
            StateMessage(
              icon: AppIcons.info,
              title: exception.localizedMessage(context),
              action: AppButton(
                label: l10n.tryAgain,
                outlined: true,
                expand: false,
                onPressed: () => context.read<NewsViewModel>().doAction(
                  const GetNewsEvent(),
                ),
              ),
            ),
          ],
          success: (news) => news.isEmpty
              ? [
                  StateMessage(
                    icon: AppIcons.news,
                    title: l10n.noNewsYet,
                    subtitle: l10n.noNewsYetSubtitle,
                  ),
                ]
              : [
                  for (final item in news)
                    NewsListCard(
                      news: item,
                      onTap: () => context.push(
                        AppRoutes.newsArticleOf(item.slug),
                        extra: item,
                      ),
                    ),
                ],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16.h,
          children: children,
        );
      },
    );
  }

  static List<Widget> _skeletons() => const [
    NewsListCardSkeleton(),
    NewsListCardSkeleton(),
  ];
}
