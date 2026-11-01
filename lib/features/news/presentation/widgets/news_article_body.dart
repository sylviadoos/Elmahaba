import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/features/news/domain/entities/news_details_entity.dart';

/// The article text, rendered from the API's HTML.
class NewsArticleBody extends StatelessWidget {
  const NewsArticleBody({super.key, required this.details});

  final NewsDetailsEntity details;

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.bodyLarge?.copyWith(
      height: 25 / 16,
      color: AppColors.ink,
    );
    final html = details.contentHtml.trim();

    // Read in the article's own language (English for now).
    return Directionality(
      textDirection: details.contentText.textDirection,
      child: html.isEmpty
          ? Text(details.excerpt, style: style)
          : HtmlWidget(
              html,
              textStyle: style,
              customStylesBuilder: (element) => switch (element.localName) {
                'p' || 'ul' || 'ol' => {'margin': '0 0 ${14.h}px 0'},
                'li' => {'margin-bottom': '${6.h}px'},
                _ => null,
              },
            ),
    );
  }
}
