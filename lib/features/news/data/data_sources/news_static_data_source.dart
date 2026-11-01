import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/config/di/data_env.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/network/status_code.dart';
import 'package:al_mahhaba_school/features/news/data/data_sources/news_remote_data_source.dart';
import 'package:al_mahhaba_school/features/news/data/models/news_details_model.dart';
import 'package:al_mahhaba_school/features/news/data/models/news_model.dart';
import 'package:al_mahhaba_school/features/news/data/static/static_news.dart';

/// Stands in for the news API with [staticNews], while
/// `AppConfig.useStaticData` is on.
@LazySingleton(as: NewsRemoteDataSource, env: [DataEnv.staticData])
class NewsStaticDataSource implements NewsRemoteDataSource {
  @override
  Future<List<NewsModel>> getNews() async => [
    for (final news in staticNews)
      NewsModel(
        id: news.id,
        slug: news.slug,
        title: news.title,
        date: news.date,
        thumbnailUrl: news.thumbnailUrl,
        excerpt: news.excerpt,
        webUrl: news.webUrl,
      ),
  ];

  @override
  Future<NewsDetailsModel> getNewsDetails(String slug) async =>
      staticNews.firstWhere(
        (news) => news.slug == slug,
        orElse: () =>
            throw const ServerException(statusCode: StatusCode.notFound),
      );
}
